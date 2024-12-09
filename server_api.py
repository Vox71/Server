from flask import Flask, request, jsonify
import psycopg2
from psycopg2 import sql

app = Flask(__name__)

# Конфигурация базы данных
DATABASE_CONFIG = {
    'dbname': 'internet_store',
    'user': 'your_user',  # замените на ваше имя пользователя
    'password': 'your_password',  # замените на ваш пароль
    'host': 'localhost',
    'port': '5432'
}

# Функция для получения соединения с базой данных
def get_db_connection():
    conn = psycopg2.connect(**DATABASE_CONFIG)
    return conn

@app.route('/products', methods=['GET'])
def get_products():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM Products;')
    products = cursor.fetchall()
    cursor.close()
    conn.close()

    return jsonify(products)


@app.route('/cart/purchase', methods=['POST'])
def purchase_cart():
    data = request.json
    cart_id = data['cart_id']
    user_id = data['user_id']

    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.callproc('purchase_cart', [cart_id, user_id])
    order_id = cursor.fetchone()[0]  # Получаем ID нового заказа
    conn.commit()
    cursor.close()
    conn.close()

    return jsonify({'message': 'Purchase successful', 'order_id': order_id})


@app.route('/cart/cancel', methods=['POST'])
def cancel_cart():
    data = request.json
    cart_id = data['cart_id']

    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.callproc('cancel_cart', [cart_id])
    conn.commit()
    cursor.close()
    conn.close()

    return jsonify({'message': 'Cart canceled'})

@app.route('/cart/add', methods=['POST'])
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


@app.route('/cart/remove', methods=['DELETE'])
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


if __name__ == '__main__':
    app.run(debug=True)