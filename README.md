# Flutter Shopping Application

A mobile shopping application developed using **Flutter** and **Dart**, integrated with a **Laravel REST API** backend. The application provides users with an interface to browse products, manage shopping carts, apply promotions, and place orders.

## Project Overview

This project was developed during my field attachment at **UBX** as part of practical software development experience.

The application demonstrates mobile application development, REST API integration, user authentication, and database-driven operations.

## Features

- **User Authentication**
  - User registration
  - User login
  - Secure API authentication using Laravel Sanctum
  - User logout

- **Product Management**
  - View available products
  - Add new products
  - Update product information
  - Delete products
  - View product descriptions, prices, quantities, and images

- **Shopping Cart**
  - Add products to cart
  - Update product quantities
  - Remove products from cart
  - Clear shopping cart
  - Retrieve cart information

- **Promotions**
  - View available promotions
  - Retrieve promotions using promotional codes

- **Order Management**
  - Place orders
  - View order history
  - View individual order details

## Technologies Used

| Technology | Purpose |
|---|---|
| Flutter | Mobile application development |
| Dart | Programming language |
| Laravel | Backend API development |
| PHP | Backend programming language |
| MariaDB/MySQL | Database management |
| REST API | Communication between frontend and backend |
| Laravel Sanctum | API authentication |
| HTTP Package | API requests |
| Shared Preferences | Local token and user information storage |
| Android Studio | Development and Android emulator |

## System Architecture

The application uses a client-server architecture.

1. **Frontend:** Flutter provides the mobile user interface.
2. **Backend:** Laravel processes API requests and application logic.
3. **Database:** MariaDB stores users, products, carts, promotions, and orders.
4. **Communication:** HTTP requests and JSON responses facilitate communication between Flutter and Laravel.

## Project Structure

```text
my_first_app/
│
├── lib/
│   ├── models/
│   │   ├── auth_model.dart
│   │   ├── cart_model.dart
│   │   ├── order_model.dart
│   │   └── promotion_model.dart
│   │
│   ├── services/
│   │   └── api_client.dart
│   │
│   ├── screens/
│   │   ├── login_page.dart
│   │   ├── register_page.dart
│   │   └── dashboard_page.dart
│   │
│   └── main.dart
│
├── android/
├── assets/
├── test/
├── pubspec.yaml
└── README.md
```

*Note: The structure above is illustrative. Adjust folder names to match the actual project.*

## Installation and Setup

### Prerequisites

Ensure that the following tools are installed:

- Flutter SDK
- Dart SDK
- Android Studio
- PHP
- Composer
- Laravel
- MariaDB or MySQL
- Git

### 1. Clone the Repository

```bash
git clone https://github.com/Chambiri-Tech/my_first_app.git
```

Navigate into the project directory:

```bash
cd my_first_app
```

### 2. Install Dependencies

Run:

```bash
flutter pub get
```

### 3. Configure the Laravel Backend

Clone or open the Laravel backend project separately.

Navigate to its directory and install dependencies:

```bash
composer install
```

Configure the database connection in the Laravel `.env` file.

Run database migrations:

```bash
php artisan migrate
```

Start the Laravel development server:

```bash
php artisan serve --host=0.0.0.0
```

### 4. Configure API Connection

The Flutter application communicates with the Laravel backend through:

```text
http://10.0.2.2:8000/api
```

This address is intended for an Android emulator communicating with a Laravel server running on the development computer.

For a physical Android device, replace `10.0.2.2` with your computer's local network IP address.

### 5. Run the Flutter Application

Start an Android emulator or connect an Android device.

Execute:

```bash
flutter run
```

## API Integration

The Flutter application communicates with the Laravel backend through REST API endpoints.

The main API operations include:

| Method | Endpoint | Description |
|---|---|---|
| POST | `/api/register` | Register a user |
| POST | `/api/login` | Authenticate a user |
| POST | `/api/logout` | Log out |
| GET | `/api/user` | Retrieve authenticated user |
| GET | `/api/products` | Retrieve products |
| POST | `/api/products` | Create a product |
| GET | `/api/cart` | Retrieve shopping cart |
| POST | `/api/cart/items` | Add cart item |
| GET | `/api/orders` | Retrieve orders |

Additional endpoints support product updates, cart management, promotions, and order operations.

## Screenshots

Application screenshots can be added below to demonstrate the user interface.

### Login Screen

_Add login screen screenshot here._

### Registration Screen

_Add registration screen screenshot here._

### Dashboard

_Add dashboard screenshot here._

### Products Screen

_Add products screen screenshot here._

### Shopping Cart

_Add shopping cart screenshot here._

### Orders Screen

_Add orders screen screenshot here._

## Learning Outcomes

Through this project, practical experience was gained in:

- Flutter mobile application development.
- Dart programming.
- REST API integration.
- Laravel backend communication.
- Database management.
- User authentication.
- State management and application navigation.
- Debugging and troubleshooting.
- Git and GitHub version control.

## Author

Developed as part of practical field attachment training at **UBX**.

**Technologies:** Flutter, Dart, Laravel, PHP, MariaDB, REST API.

## License

This project was developed for educational and practical software development purposes.
