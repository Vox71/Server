import random
from flask import Flask, request, jsonify
import psycopg2
from prometheus_flask_exporter import PrometheusMetrics
from flasgger import Swagger

app = Flask(__name__)
app.debug = False
metrics = PrometheusMetrics(app)
swagger = Swagger(app)
# def time_request(func):
#     @functools.wraps(func)  # Сохраняем метаданные оригинальной функции
#     def wrapper(*args, **kwargs):
#         start_time = time.time()  # Запоминаем время начала
#         response = func(*args, **kwargs)  # Выполняем основной обработчик
#         duration = time.time() - start_time  # Вычисляем длительность
#         logging.info(f"{duration:.4f}")  # Логируем только длительность в секундах
#         return response
#     return wrapper

def get_db_connection():
    lever = random.choice([1, 2])
    if lever == 1:
        conn = psycopg2.connect(database='online_store', user='postgres', password='password', host='172.23.0.5', port=5432)
        return conn
    else:
        conn = psycopg2.connect(database='online_store', user='postgres', password='password', host='172.23.0.6', port=5432)
        return conn

@app.route('/')
def main():
    pass 

@app.route('/products', methods=['GET'])
def get_products():
    """
    Get products
    ---
    responses:
      200:
        description: Get all products
    """    
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM Products;')
    products = cursor.fetchall()
    cursor.close()
    conn.close()

    return jsonify(products)

@app.route('/cart/add', methods=['POST'])
# @time_request
def add_to_cart():
    """
    Добавляет товар в корзину.
    ---
    tags:
      - Cart
    parameters:
      - name: cart_id
        in: body
        type: integer
        required: true
        description: ID корзины
      - name: product_id
        in: body
        type: integer
        required: true
        description: ID товара
      - name: quantity
        in: body
        type: integer
        required: true
        description: Количество товара
    responses:
      200:
        description: Товар успешно добавлен в корзину
        schema:
          type: object
          properties:
            message:
              type: string
              example: "Product added to cart"
      400:
        description: Неверный запрос (например, отсутствуют необходимые поля)
        schema:
          type: object
          properties:
            message:
              type: string
              example: "Bad request: Missing required fields"
      404:
        description: Корзина не найдена
        schema:
          type: object
          properties:
            message:
              type: string
              example: "Cart not found"
      500:
        description: Внутренняя ошибка сервера
        schema:
          type: object
          properties:
            message:
              type: string
              example: "Internal server error"
    """

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

@app.route('/cart/update', methods=['PUT'])
# @time_request
def update_cart_item():
    """
    Обновляет количество товаров в корзине
    ---
    parameters:
      - name: cart_id
        in: body
        type: integer
        required: true
        description: ID корзины
      - name: product_id
        in: body
        type: integer
        required: true
        description: ID товара для обновления
      - name: quantity
        in: body
        type: integer
        required: true
        description: Новое количество товара
    responses:
      200:
        description: Товар в корзине успешно обновлен
        schema:
          id: UpdateResponse
          properties:
            message:
              type: string
              example: Cart item updated successfully
      404:
        description: Item not found in cart
    """
    data = request.json
    cart_id = data['cart_id']
    product_id = data['product_id']
    quantity = data['quantity']
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        'UPDATE Cart_Items SET quantity = %s WHERE cart_id = %s AND product_id = %s',
        (quantity, cart_id, product_id)
    )
    if cursor.rowcount == 0:
        return jsonify({'message': 'Item not found in cart'}), 404

    conn.commit()
    cursor.close()
    conn.close()
    return jsonify({'message': 'Cart item updated successfully'})


@app.route('/cart/remove', methods=['DELETE'])
# @time_request
def remove_from_cart():
    """
    Удалить продукт из корзины
    ---
    tags:
      - Cart
    parameters:
      - name: cart_id
        in: body
        type: integer
        required: true
        description: ID корзины
      - name: product_id
        in: body
        type: integer
        required: true
        description: ID продукта для удаления
    responses:
      200:
        description: Продукт успешно удален из корзины
        schema:
          type: object
          properties:
            message:
              type: string
              example: 'Product removed from cart'
      404:
        description: Корзина или продукт не найдены
        schema:
          type: object
          properties:
            error:
              type: string
              example: 'Cart not found or product not found'
      500:
        description: Ошибка сервера
        schema:
          type: object
          properties:
            error:
              type: string
              example: 'An error occurred: <error_message>'
    """

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
    """
    Оформить заказ
    ---
    parameters:
      - name: cart_id
        in: body
        type: integer
        required: true
        description: ID корзины для оформления
        schema:
          type: object
          properties:
            cart_id:
              type: integer
    responses:
      201:
        description: Заказ создан
        schema:
          type: object
          properties:
            message:
              type: string
              example: Order created successfully
            order_id:
              type: integer
              example: 123

      400:
        description: Корзина пустая
        schema:
          type: object
          properties:
            error:
              type: string
              example: Cart is empty
      404:
        description: Корзина не найдена
        schema:
          type: object
          properties:
            error:
              type: string
              example: Cart not found

      500:
        description: Ошибка БД
        schema:
          type: object
          properties:
            error:
              type: string
              example: Error message
    """
    data = request.json
    cart_id = data['cart_id']
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute('SELECT user_id FROM cart WHERE id = %s;', (cart_id,))
        cart = cursor.fetchone()
        if not cart:
            return jsonify({'error': 'Cart not found'}), 404

        cursor.execute('SELECT product_id, quantity FROM cart_items WHERE cart_id = %s;', (cart_id,))
        cart_items = cursor.fetchall()
        if not cart_items:
            return jsonify({'error': 'Cart is empty'}), 400

        cursor.execute('INSERT INTO orders (user_id) VALUES (%s) RETURNING id;', (cart[0],))
        order_id = cursor.fetchone()[0]
        for item in cart_items:
            cursor.execute('INSERT INTO order_items (order_id, product_id, quantity) VALUES (%s, %s, %s);', (order_id, item[0], item[1]))
        cursor.execute('DELETE FROM cart_items WHERE cart_id = %s;', (cart_id,))
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
    """
    Создать нового пользователя
    ---
    tags:
      - User
    parameters:
      - name: user_id
        in: body
        type: integer
        required: true
        description: Уникальный идентификатор пользователя
    responses:
      200:
        description: Пользователь создан
        schema:
          type: object
          properties:
            message:
              type: string
              example: "user created"
      400:
        description: Неправильные входные данные
        schema:
          type: object
          properties:
            message:
              type: string
              example: "Bad Request: Missing user_id"
      500:
        description: Ошибка БД
        schema:
          type: object
          properties:
            message:
              type: string
              example: "Internal Server Error: Could not create user"
    """
    data = request.json
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

@app.route('/cart/get', methods=['GET'])
def cart_get():
    """
    Получить товары из корзины.
    ---
    tags:
      - Cart

    parameters:
      - name: cart_id
        in: query
        type: integer
        required: true
        description: ID корзины, для которой нужно получить товары.
    responses:
      200:
        description: Успешно получены товары из корзины.
        schema:
          id: CartGetResponse
          properties:
            items:
              type: array
              items:
                type: object
                properties:
                  item_id:
                    type: integer
                    example: 1
                  quantity:
                    type: integer
                    example: 2
      400:
        description: Неверный запрос, отсутствуют необходимые параметры.
        schema:
          id: BadRequestResponse
          properties:
            message:
              type: string
              example: "Invalid input"
      404:
        description: Корзина не найдена.
        schema:
          id: NotFoundResponse
          properties:
            message:
              type: string
              example: "Cart not found"
      500:
        description: Внутренняя ошибка сервера.
        schema:
          id: InternalServerErrorResponse
          properties:
            message:
              type: string
              example: "Internal server error"
    """
    data = request.json
    i = data['cart_i']
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('SELECT FROM Cart_Items WHERE cart_id = %s',
                   (i))
    cart_items = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify(cart_items)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)