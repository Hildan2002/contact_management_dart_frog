# Contact Management API Documentation

## Base URL
```
http://localhost:8080
```

## Authentication
This API uses JWT (JSON Web Token) for authentication. After successful login, include the token in the Authorization header for protected endpoints.

### Authentication Header Format
```
Authorization: Bearer <jwt_token>
```

---

## Authentication Endpoints

### Register User
Create a new user account.

**Endpoint:** `POST /auth/register`

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john.doe@example.com",
  "password": "SecurePassword123!"
}
```

**Success Response (201 Created):**
```json
{
  "data": {
    "email": "john.doe@example.com",
    "name": "John Doe"
  }
}
```

**Error Responses:**
- `400 Bad Request`: Validation error or user already exists
- `405 Method Not Allowed`: Invalid HTTP method

---

### Login User
Authenticate user and receive JWT tokens.

**Endpoint:** `POST /auth/login`

**Request Body:**
```json
{
  "email": "john.doe@example.com",
  "password": "SecurePassword123!"
}
```

**Success Response (200 OK):**
```json
{
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "refresh_token_here"
  }
}
```

**Error Responses:**
- `400 Bad Request`: Validation error
- `401 Unauthorized`: Invalid credentials
- `405 Method Not Allowed`: Invalid HTTP method

---

## Contact Endpoints
All contact endpoints require authentication.

### Get All Contacts
Retrieve all contacts for the authenticated user with optional pagination and search.

**Endpoint:** `GET /contacts`

**Query Parameters:**
- `limit` (optional): Number of contacts to return (must be >= 1)
- `offset` (optional): Number of contacts to skip (must be >= 0)
- `q` (optional): Search query to filter contacts

**Example Requests:**
```
GET /contacts
GET /contacts?limit=10&offset=0
GET /contacts?q=john
GET /contacts?limit=5&q=example.com
```

**Success Response (200 OK):**
```json
{
  "contacts": [
    {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "user_id": "user_id_here",
      "first_name": "John",
      "last_name": "Doe",
      "email": "john.doe@example.com",
      "phone": "+1234567890",
      "company": "Acme Corp",
      "address": "123 Main St, City, State 12345",
      "notes": "Important client contact",
      "created_at": "2024-01-15T10:30:00.000Z",
      "updated_at": "2024-01-15T10:30:00.000Z"
    }
  ],
  "total": 1
}
```

**Error Responses:**
- `400 Bad Request`: Invalid limit or offset parameter
- `401 Unauthorized`: Missing or invalid authentication token
- `500 Internal Server Error`: Failed to retrieve contacts

---

### Create Contact
Create a new contact for the authenticated user.

**Endpoint:** `POST /contacts`

**Request Body:**
```json
{
  "first_name": "Jane",
  "last_name": "Smith",
  "email": "jane.smith@example.com",
  "phone": "+1987654321",
  "company": "Tech Solutions Inc",
  "address": "456 Oak Ave, City, State 54321",
  "notes": "Met at tech conference"
}
```

**Required Fields:**
- `first_name`: String
- `last_name`: String
- `email`: String (valid email format)

**Optional Fields:**
- `phone`: String
- `company`: String
- `address`: String
- `notes`: String

**Success Response (201 Created):**
```json
{
  "contact": {
    "id": "987fcdeb-51a2-43d7-8f9e-123456789abc",
    "user_id": "user_id_here",
    "first_name": "Jane",
    "last_name": "Smith",
    "email": "jane.smith@example.com",
    "phone": "+1987654321",
    "company": "Tech Solutions Inc",
    "address": "456 Oak Ave, City, State 54321",
    "notes": "Met at tech conference",
    "created_at": "2024-01-15T11:30:00.000Z",
    "updated_at": "2024-01-15T11:30:00.000Z"
  }
}
```

**Error Responses:**
- `400 Bad Request`: Validation error
- `401 Unauthorized`: Missing or invalid authentication token
- `405 Method Not Allowed`: Invalid HTTP method
- `500 Internal Server Error`: Failed to create contact

---

### Get Single Contact
Retrieve a specific contact by ID.

**Endpoint:** `GET /contacts/{id}`

**Path Parameters:**
- `id`: Contact UUID

**Example Request:**
```
GET /contacts/123e4567-e89b-12d3-a456-426614174000
```

**Success Response (200 OK):**
```json
{
  "contact": {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "user_id": "user_id_here",
    "first_name": "John",
    "last_name": "Doe",
    "email": "john.doe@example.com",
    "phone": "+1234567890",
    "company": "Acme Corp",
    "address": "123 Main St, City, State 12345",
    "notes": "Important client contact",
    "created_at": "2024-01-15T10:30:00.000Z",
    "updated_at": "2024-01-15T10:30:00.000Z"
  }
}
```

**Error Responses:**
- `401 Unauthorized`: Missing or invalid authentication token
- `404 Not Found`: Contact not found or doesn't belong to user
- `405 Method Not Allowed`: Invalid HTTP method
- `500 Internal Server Error`: Failed to retrieve contact

---

### Update Contact
Update an existing contact.

**Endpoint:** `PUT /contacts/{id}`

**Path Parameters:**
- `id`: Contact UUID

**Request Body:**
```json
{
  "first_name": "John",
  "last_name": "Doe Updated",
  "email": "john.doe.updated@example.com",
  "phone": "+1234567890",
  "company": "Updated Corp",
  "address": "789 Updated St, City, State 67890",
  "notes": "Updated notes"
}
```

**Required Fields:**
- `first_name`: String
- `last_name`: String
- `email`: String (valid email format)

**Optional Fields:**
- `phone`: String
- `company`: String
- `address`: String
- `notes`: String

**Success Response (200 OK):**
```json
{
  "contact": {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "user_id": "user_id_here",
    "first_name": "John",
    "last_name": "Doe Updated",
    "email": "john.doe.updated@example.com",
    "phone": "+1234567890",
    "company": "Updated Corp",
    "address": "789 Updated St, City, State 67890",
    "notes": "Updated notes",
    "created_at": "2024-01-15T10:30:00.000Z",
    "updated_at": "2024-01-15T12:30:00.000Z"
  }
}
```

**Error Responses:**
- `400 Bad Request`: Validation error
- `401 Unauthorized`: Missing or invalid authentication token
- `404 Not Found`: Contact not found or doesn't belong to user
- `405 Method Not Allowed`: Invalid HTTP method
- `500 Internal Server Error`: Failed to update contact

---

### Delete Contact
Delete an existing contact.

**Endpoint:** `DELETE /contacts/{id}`

**Path Parameters:**
- `id`: Contact UUID

**Example Request:**
```
DELETE /contacts/123e4567-e89b-12d3-a456-426614174000
```

**Success Response (200 OK):**
```json
{
  "message": "Contact deleted successfully"
}
```

**Error Responses:**
- `401 Unauthorized`: Missing or invalid authentication token
- `404 Not Found`: Contact not found or doesn't belong to user
- `405 Method Not Allowed`: Invalid HTTP method
- `500 Internal Server Error`: Failed to delete contact

---

## Error Response Format

All error responses follow this format:

```json
{
  "error": "Error message description"
}
```

### Common HTTP Status Codes

- `200 OK`: Request successful
- `201 Created`: Resource created successfully
- `400 Bad Request`: Invalid request data or validation error
- `401 Unauthorized`: Authentication required or invalid token
- `404 Not Found`: Resource not found
- `405 Method Not Allowed`: HTTP method not supported for endpoint
- `500 Internal Server Error`: Server-side error

---

## Validation Rules

### User Registration
- `name`: Required, non-empty string
- `email`: Required, valid email format
- `password`: Required, minimum 8 characters with complexity requirements

### User Login
- `email`: Required, valid email format
- `password`: Required, non-empty string

### Contact Data
- `first_name`: Required, non-empty string
- `last_name`: Required, non-empty string
- `email`: Required, valid email format
- `phone`: Optional string
- `company`: Optional string
- `address`: Optional string
- `notes`: Optional string

---

## Example API Usage

### Complete Authentication Flow

1. **Register a new user:**
```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john.doe@example.com",
    "password": "SecurePassword123!"
  }'
```

2. **Login to get token:**
```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john.doe@example.com",
    "password": "SecurePassword123!"
  }'
```

3. **Use token for protected endpoints:**
```bash
curl -X GET http://localhost:8080/contacts \
  -H "Authorization: Bearer your_jwt_token_here"
```

### Contact Management Flow

1. **Create a contact:**
```bash
curl -X POST http://localhost:8080/contacts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your_jwt_token_here" \
  -d '{
    "first_name": "Jane",
    "last_name": "Smith",
    "email": "jane.smith@example.com",
    "phone": "+1987654321",
    "company": "Tech Solutions Inc"
  }'
```

2. **Get all contacts:**
```bash
curl -X GET http://localhost:8080/contacts \
  -H "Authorization: Bearer your_jwt_token_here"
```

3. **Update a contact:**
```bash
curl -X PUT http://localhost:8080/contacts/contact_id_here \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your_jwt_token_here" \
  -d '{
    "first_name": "Jane",
    "last_name": "Smith Updated",
    "email": "jane.smith.updated@example.com"
  }'
```

4. **Delete a contact:**
```bash
curl -X DELETE http://localhost:8080/contacts/contact_id_here \
  -H "Authorization: Bearer your_jwt_token_here"
```

---

## Security Notes

- All passwords are bcrypt hashed before storage
- JWT tokens have a 7-day expiration period
- Users can only access their own contacts (data isolation)
- All endpoints use parameterized queries to prevent SQL injection
- Input validation is performed on all endpoints
- CORS headers are configured for cross-origin requests

---

## Rate Limiting

Currently, no rate limiting is implemented. Consider implementing rate limiting for production use.

---

## Versioning

This API is currently unversioned. Future versions may include version prefixes (e.g., `/v1/contacts`).