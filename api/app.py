#!/usr/bin/env python3
"""
Optimized API Service for Ubuntu Runner
Demonstrates best practices for API optimization including:
- Query optimization
- Response caching
- Pagination
- Connection pooling
"""

from flask import Flask, jsonify, request, g
from flask_caching import Cache
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from functools import wraps
import sqlite3
import json
import hashlib
import time
from datetime import datetime, timedelta
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize Flask app with optimizations
app = Flask(__name__)
app.config['JSON_SORT_KEYS'] = False  # Avoid unnecessary sorting overhead

# Configure caching
cache_config = {
    'CACHE_TYPE': 'simple',  # Use 'redis' in production
    'CACHE_DEFAULT_TIMEOUT': 300,  # 5 minutes default
    'CACHE_THRESHOLD': 1000  # Maximum number of items the cache will store
}
app.config.from_mapping(cache_config)
cache = Cache(app)

# Configure rate limiting
limiter = Limiter(
    app=app,
    key_func=get_remote_address,
    default_limits=["1000 per hour", "100 per minute"]
)

# Database configuration
DATABASE = 'api_data.db'
POOL_SIZE = 10

# Connection pool
connection_pool = []

def get_db():
    """Get database connection from pool or create new one."""
    db = getattr(g, '_database', None)
    if db is None:
        if connection_pool:
            db = connection_pool.pop()
            logger.info(f"Reusing connection from pool. Pool size: {len(connection_pool)}")
        else:
            db = sqlite3.connect(DATABASE)
            db.row_factory = sqlite3.Row
            logger.info("Created new database connection")
        g._database = db
    return db

def return_connection(db):
    """Return connection to pool if not full."""
    if len(connection_pool) < POOL_SIZE:
        connection_pool.append(db)
        logger.info(f"Returned connection to pool. Pool size: {len(connection_pool)}")
    else:
        db.close()
        logger.info("Closed connection (pool full)")

@app.teardown_appcontext
def close_connection(exception):
    """Return database connection to pool on request end."""
    db = getattr(g, '_database', None)
    if db is not None:
        return_connection(db)

def init_db():
    """Initialize database with sample data."""
    with app.app_context():
        db = get_db()
        db.executescript('''
            CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT UNIQUE NOT NULL,
                email TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                active BOOLEAN DEFAULT 1
            );

            CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
            CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
            CREATE INDEX IF NOT EXISTS idx_users_active ON users(active);

            CREATE TABLE IF NOT EXISTS projects (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                description TEXT,
                user_id INTEGER,
                status TEXT DEFAULT 'active',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(id)
            );

            CREATE INDEX IF NOT EXISTS idx_projects_user_id ON projects(user_id);
            CREATE INDEX IF NOT EXISTS idx_projects_status ON projects(status);
            CREATE INDEX IF NOT EXISTS idx_projects_created_at ON projects(created_at);

            CREATE TABLE IF NOT EXISTS tasks (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                description TEXT,
                project_id INTEGER,
                assigned_to INTEGER,
                status TEXT DEFAULT 'pending',
                priority INTEGER DEFAULT 0,
                due_date TIMESTAMP,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (project_id) REFERENCES projects(id),
                FOREIGN KEY (assigned_to) REFERENCES users(id)
            );

            CREATE INDEX IF NOT EXISTS idx_tasks_project_id ON tasks(project_id);
            CREATE INDEX IF NOT EXISTS idx_tasks_assigned_to ON tasks(assigned_to);
            CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks(status);
            CREATE INDEX IF NOT EXISTS idx_tasks_priority ON tasks(priority);
        ''')

        # Insert sample data if tables are empty
        cursor = db.execute('SELECT COUNT(*) as count FROM users')
        if cursor.fetchone()['count'] == 0:
            # Insert sample users
            for i in range(1, 101):
                db.execute(
                    'INSERT INTO users (username, email) VALUES (?, ?)',
                    (f'user{i}', f'user{i}@example.com')
                )

            # Insert sample projects
            for i in range(1, 201):
                db.execute(
                    'INSERT INTO projects (name, description, user_id, status) VALUES (?, ?, ?, ?)',
                    (f'Project {i}', f'Description for project {i}', (i % 100) + 1,
                     'active' if i % 3 != 0 else 'completed')
                )

            # Insert sample tasks
            for i in range(1, 501):
                db.execute(
                    'INSERT INTO tasks (title, description, project_id, assigned_to, status, priority) VALUES (?, ?, ?, ?, ?, ?)',
                    (f'Task {i}', f'Description for task {i}', (i % 200) + 1, (i % 100) + 1,
                     ['pending', 'in_progress', 'completed'][i % 3], i % 5)
                )

            db.commit()
            logger.info("Sample data inserted")

def make_cache_key(*args, **kwargs):
    """Generate cache key from request parameters."""
    path = request.path
    args = str(hash(frozenset(request.args.items())))
    return f"{path}:{args}"

def paginate_query(query, params=None, page=1, per_page=20):
    """
    Paginate SQL query results.
    Returns paginated results with metadata.
    """
    db = get_db()

    # Count total records
    count_query = f"SELECT COUNT(*) as total FROM ({query}) as subquery"
    total = db.execute(count_query, params or []).fetchone()['total']

    # Calculate pagination
    total_pages = (total + per_page - 1) // per_page
    offset = (page - 1) * per_page

    # Execute paginated query
    paginated_query = f"{query} LIMIT ? OFFSET ?"
    params = (params or []) + [per_page, offset]

    cursor = db.execute(paginated_query, params)
    items = [dict(row) for row in cursor.fetchall()]

    return {
        'items': items,
        'pagination': {
            'page': page,
            'per_page': per_page,
            'total': total,
            'total_pages': total_pages,
            'has_next': page < total_pages,
            'has_prev': page > 1
        }
    }

def etag_cache(f):
    """Decorator to add ETag support for caching."""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        # Generate response
        response_data = f(*args, **kwargs)
        response_json = json.dumps(response_data, sort_keys=True)

        # Generate ETag
        etag = hashlib.md5(response_json.encode()).hexdigest()

        # Check if client has matching ETag
        if request.headers.get('If-None-Match') == etag:
            return '', 304  # Not Modified

        # Return response with ETag header
        response = jsonify(response_data)
        response.headers['ETag'] = etag
        response.headers['Cache-Control'] = 'private, max-age=300'
        return response

    return decorated_function

# API Routes

@app.route('/health')
@cache.cached(timeout=10)
def health_check():
    """Health check endpoint with system status."""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat(),
        'cache_active': cache.cache is not None,
        'connection_pool_size': len(connection_pool)
    })

@app.route('/api/users')
@limiter.limit("100 per minute")
@cache.cached(timeout=60, key_prefix=make_cache_key)
@etag_cache
def get_users():
    """
    Get paginated list of users.
    Query optimization: Uses indexes and pagination.
    """
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 20, type=int)
    per_page = min(per_page, 100)  # Limit max per_page

    # Filter parameters
    active_only = request.args.get('active', 'true').lower() == 'true'
    search = request.args.get('search', '')

    # Build optimized query
    query = 'SELECT id, username, email, created_at, active FROM users WHERE 1=1'
    params = []

    if active_only:
        query += ' AND active = 1'

    if search:
        query += ' AND (username LIKE ? OR email LIKE ?)'
        search_pattern = f'%{search}%'
        params.extend([search_pattern, search_pattern])

    query += ' ORDER BY id'

    result = paginate_query(query, params, page, per_page)
    return result

@app.route('/api/projects')
@limiter.limit("100 per minute")
@cache.cached(timeout=30, key_prefix=make_cache_key)
@etag_cache
def get_projects():
    """
    Get paginated list of projects with optimized queries.
    Includes user information through JOIN.
    """
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 20, type=int)
    per_page = min(per_page, 100)

    user_id = request.args.get('user_id', type=int)
    status = request.args.get('status', '')

    # Optimized query with JOIN
    query = '''
        SELECT
            p.id,
            p.name,
            p.description,
            p.status,
            p.created_at,
            p.updated_at,
            u.username as owner_username,
            u.email as owner_email
        FROM projects p
        LEFT JOIN users u ON p.user_id = u.id
        WHERE 1=1
    '''
    params = []

    if user_id:
        query += ' AND p.user_id = ?'
        params.append(user_id)

    if status:
        query += ' AND p.status = ?'
        params.append(status)

    query += ' ORDER BY p.created_at DESC'

    result = paginate_query(query, params, page, per_page)
    return result

@app.route('/api/tasks')
@limiter.limit("100 per minute")
@cache.cached(timeout=30, key_prefix=make_cache_key)
@etag_cache
def get_tasks():
    """
    Get paginated list of tasks with advanced filtering.
    Demonstrates complex query optimization.
    """
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 20, type=int)
    per_page = min(per_page, 100)

    project_id = request.args.get('project_id', type=int)
    assigned_to = request.args.get('assigned_to', type=int)
    status = request.args.get('status', '')
    priority = request.args.get('priority', type=int)

    # Complex optimized query with multiple JOINs
    query = '''
        SELECT
            t.id,
            t.title,
            t.description,
            t.status,
            t.priority,
            t.due_date,
            t.created_at,
            p.name as project_name,
            u.username as assigned_to_username
        FROM tasks t
        LEFT JOIN projects p ON t.project_id = p.id
        LEFT JOIN users u ON t.assigned_to = u.id
        WHERE 1=1
    '''
    params = []

    if project_id:
        query += ' AND t.project_id = ?'
        params.append(project_id)

    if assigned_to:
        query += ' AND t.assigned_to = ?'
        params.append(assigned_to)

    if status:
        query += ' AND t.status = ?'
        params.append(status)

    if priority is not None:
        query += ' AND t.priority = ?'
        params.append(priority)

    # Order by priority and creation date for optimal task viewing
    query += ' ORDER BY t.priority DESC, t.created_at DESC'

    result = paginate_query(query, params, page, per_page)
    return result

@app.route('/api/statistics')
@cache.cached(timeout=300)  # Cache for 5 minutes
def get_statistics():
    """
    Get aggregated statistics.
    Demonstrates query optimization for analytics.
    """
    db = get_db()

    # Use single query with subqueries for efficiency
    stats_query = '''
        SELECT
            (SELECT COUNT(*) FROM users WHERE active = 1) as active_users,
            (SELECT COUNT(*) FROM projects WHERE status = 'active') as active_projects,
            (SELECT COUNT(*) FROM tasks WHERE status != 'completed') as pending_tasks,
            (SELECT COUNT(*) FROM tasks WHERE status = 'completed') as completed_tasks,
            (SELECT AVG(priority) FROM tasks WHERE status != 'completed') as avg_priority
    '''

    stats = dict(db.execute(stats_query).fetchone())

    # Get task distribution by status (using GROUP BY for efficiency)
    distribution_query = '''
        SELECT status, COUNT(*) as count
        FROM tasks
        GROUP BY status
    '''

    distribution = {}
    for row in db.execute(distribution_query):
        distribution[row['status']] = row['count']

    stats['task_distribution'] = distribution

    return jsonify(stats)

@app.route('/api/search')
@limiter.limit("50 per minute")
@cache.cached(timeout=60, key_prefix=make_cache_key)
def search():
    """
    Global search endpoint with optimized full-text search.
    """
    query = request.args.get('q', '')
    if not query or len(query) < 3:
        return jsonify({'error': 'Search query must be at least 3 characters'}), 400

    db = get_db()
    search_pattern = f'%{query}%'
    results = {
        'users': [],
        'projects': [],
        'tasks': []
    }

    # Search users (limited results for performance)
    user_results = db.execute(
        'SELECT id, username, email FROM users WHERE username LIKE ? OR email LIKE ? LIMIT 10',
        (search_pattern, search_pattern)
    ).fetchall()
    results['users'] = [dict(row) for row in user_results]

    # Search projects
    project_results = db.execute(
        'SELECT id, name, status FROM projects WHERE name LIKE ? OR description LIKE ? LIMIT 10',
        (search_pattern, search_pattern)
    ).fetchall()
    results['projects'] = [dict(row) for row in project_results]

    # Search tasks
    task_results = db.execute(
        'SELECT id, title, status, priority FROM tasks WHERE title LIKE ? OR description LIKE ? LIMIT 10',
        (search_pattern, search_pattern)
    ).fetchall()
    results['tasks'] = [dict(row) for row in task_results]

    return jsonify(results)

@app.route('/api/cache/clear', methods=['POST'])
@limiter.limit("5 per hour")
def clear_cache():
    """Clear all cached data."""
    cache.clear()
    return jsonify({'message': 'Cache cleared successfully'})

@app.errorhandler(429)
def ratelimit_handler(e):
    """Handle rate limit exceeded."""
    return jsonify({
        'error': 'Rate limit exceeded',
        'message': str(e.description)
    }), 429

@app.errorhandler(500)
def internal_error(error):
    """Handle internal server errors."""
    logger.error(f"Internal error: {error}")
    return jsonify({
        'error': 'Internal server error',
        'message': 'An unexpected error occurred'
    }), 500

if __name__ == '__main__':
    # Initialize database
    init_db()

    # Run application
    app.run(debug=False, host='0.0.0.0', port=5000, threaded=True)