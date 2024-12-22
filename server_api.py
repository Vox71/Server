import functools
import random
import time
from flask import Flask, request, jsonify
import logging
import psycopg2
from psycopg2 import OperationalError, sql
from prometheus_client import Counter, generate_latest, CollectorRegistry
from prometheus_client import make_wsgi_app
from werkzeug.middleware.dispatcher import DispatcherMiddleware
from prometheus_flask_exporter import PrometheusMetrics

app = Flask(__name__)

# REQUEST_COUNT = Counter('request_count', 'Total number of requests')

metrics = PrometheusMetrics(app)
# Конфигурация базы данных

# def time_request(func):
#     @functools.wraps(func)  # Сохраняем метаданные оригинальной функции
#     def wrapper(*args, **kwargs):
#         start_time = time.time()  # Запоминаем время начала
#         response = func(*args, **kwargs)  # Выполняем основной обработчик
#         duration = time.time() - start_time  # Вычисляем длительность
#         logging.info(f"{duration:.4f}")  # Логируем только длительность в секундах
#         return response
#     return wrapper

# pgpool_addresses = [('172.23.0.5', 5432), ('172.23.0.6', 5432)]
# lever = 'left'

def get_db_connection():
    lever = random.choice([1, 2])
    if lever == 1:
        conn = psycopg2.connect(database='online_store', user='postgres', password='password', host='172.23.0.5', port=5432)
        return conn
    else:
        conn = psycopg2.connect(database='online_store', user='postgres', password='password', host='172.23.0.6', port=5432)
        return conn

@app.route('/products', methods=['GET'])
def get_products():
    # REQUEST_COUNT.inc()
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM Products;')
    products = cursor.fetchall()
    cursor.close()
    conn.close()

    return jsonify(products)

# @app.route('/test', methods=['GET'])
# def get_somtihs():

#     products = 'sometext'


#     return jsonify(products)

# @app.route('/cart/purchase', methods=['POST'])
# @time_request
# def purchase_cart():
#     data = request.json
#     cart_id = data['cart_id']
#     user_id = data['user_id']
#     conn = get_db_connection()
#     cursor = conn.cursor()
#     cursor.callproc('purchase_cart', [cart_id, user_id])
#     order_id = cursor.fetchone()[0]  # Получаем ID нового заказа
#     conn.commit()
#     cursor.close()
#     conn.close()

#     return jsonify({'message': 'Purchase successful', 'order_id': order_id})

@app.route('/cart/add', methods=['POST'])
# @time_request
def add_to_cart():
    data = request.json
    cart_id = data['cart_id']
    product_id = data['product_id']
    quantity = data['quantity']

    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        'INSERT INTO Cart_Items (cart_id, product_id, quantity) VALUES (%s, %s, %s)',
        (cart_id, product_id, quantity)
    )
    conn.commit()
    cursor.close()
    conn.close()

    return jsonify({'message': 'Product added to cart'})

@app.route('/cart/update', methods=['POST'])
# @time_request
def update_cart_item():
    data = request.json
    cart_id = data['cart_id']
    product_id = data['product_id']
    quantity = data['quantity']

    conn = get_db_connection()
    cursor = conn.cursor()
    
    # Обновляем количество товара в корзине
    cursor.execute(
        'UPDATE Cart_Items SET quantity = %s WHERE cart_id = %s AND product_id = %s',
        (quantity, cart_id, product_id)
    )
    
    # Проверяем, было ли обновлено хотя бы одно значение
    if cursor.rowcount == 0:
        return jsonify({'message': 'Item not found in cart'}), 404

    conn.commit()
    cursor.close()
    conn.close()

    return jsonify({'message': 'Cart item updated successfully'})


@app.route('/cart/remove', methods=['DELETE'])
# @time_request
def remove_from_cart():
    data = request.json
    cart_id = data['cart_id']
    product_id = data['product_id']

    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        'DELETE FROM Cart_Items WHERE cart_id = %s AND product_id = %s',
        (cart_id, product_id)
    )
    conn.commit()
    cursor.close()
    conn.close()

    return jsonify({'message': 'Product removed from cart'})

@app.route('/checkout', methods=['POST'])
# @time_request
def checkout():
    data = request.json # Получаем данные из JSON
    cart_id = data['cart_id']

    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        # Получаем корзину
        cursor.execute('SELECT user_id FROM cart WHERE id = %s;', (cart_id,))
        cart = cursor.fetchone()
        if not cart:
            return jsonify({'error': 'Cart not found'}), 404

        # Получаем элементы корзины
        cursor.execute('SELECT product_id, quantity FROM cart_items WHERE cart_id = %s;', (cart_id,))
        cart_items = cursor.fetchall()
        if not cart_items:
            return jsonify({'error': 'Cart is empty'}), 400

        # Создаем новый заказ
        cursor.execute('INSERT INTO orders (user_id) VALUES (%s) RETURNING id;', (cart[0],))
        order_id = cursor.fetchone()[0]

        # Создаем элементы заказа на основе элементов корзины
        for item in cart_items:
            cursor.execute('INSERT INTO order_items (order_id, product_id, quantity) VALUES (%s, %s, %s);', (order_id, item[0], item[1]))

        # Удаляем элементы из корзины
        cursor.execute('DELETE FROM cart_items WHERE cart_id = %s;', (cart_id,))

        # Сохраняем изменения в БД
        conn.commit()
        return jsonify({'message': 'Order created successfully', 'order_id': order_id}), 201
    except Exception as e:
        conn.rollback()
        return jsonify({'error': 'An error occurred: ' + str(e)}), 500
    finally:
        cursor.close()
        conn.close()

@app.route('/user/add', methods=['POST'])
# @time_request
def create_user():
    data = request.json # Получаем данные из JSON
    i = data['user_id']
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        'INSERT INTO cart (id, user_id) VALUES (%s, %s)',
        (i, i)
    )
    conn.commit()
    cursor.close()
    conn.close()
    return jsonify({'message': 'user created'})

# @app.route('/metrics')
# def metrics():
#     return generate_latest(), 200, {'Content-Type': 'text/plain; version=0.0.4; charset=utf-8'}

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug='False')