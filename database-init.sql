-- CRM Database Schema
-- MySQL Database initialization script

CREATE DATABASE IF NOT EXISTS crm_database;
USE crm_database;

-- Users table
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    role ENUM('admin', 'user', 'manager') DEFAULT 'user',
    phone VARCHAR(20),
    avatar TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_users_email (email),
    INDEX idx_users_role (role),
    INDEX idx_users_active (is_active)
);

-- Customers table
CREATE TABLE customers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(20),
    company VARCHAR(255),
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    zip_code VARCHAR(20),
    country VARCHAR(100),
    customer_type ENUM('lead', 'prospect', 'customer', 'inactive') DEFAULT 'lead',
    source VARCHAR(100),
    notes TEXT,
    assigned_to INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_customers_email (email),
    INDEX idx_customers_type (customer_type),
    INDEX idx_customers_assigned (assigned_to),
    INDEX idx_customers_company (company)
);

-- Deals table
CREATE TABLE deals (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    value DECIMAL(15,2),
    currency VARCHAR(3) DEFAULT 'USD',
    stage ENUM('prospect', 'qualified', 'proposal', 'negotiation', 'closed_won', 'closed_lost') DEFAULT 'prospect',
    probability INT DEFAULT 0,
    expected_close_date DATE,
    actual_close_date DATE,
    assigned_to INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_deals_customer (customer_id),
    INDEX idx_deals_stage (stage),
    INDEX idx_deals_assigned (assigned_to),
    INDEX idx_deals_close_date (expected_close_date)
);

-- Activities table
CREATE TABLE activities (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    user_id INT,
    deal_id INT,
    type ENUM('call', 'email', 'meeting', 'task', 'note') NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    duration INT, -- in minutes
    outcome TEXT,
    next_action TEXT,
    status ENUM('pending', 'completed', 'cancelled') DEFAULT 'pending',
    scheduled_at TIMESTAMP,
    completed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (deal_id) REFERENCES deals(id) ON DELETE SET NULL,
    INDEX idx_activities_customer (customer_id),
    INDEX idx_activities_user (user_id),
    INDEX idx_activities_type (type),
    INDEX idx_activities_status (status),
    INDEX idx_activities_scheduled (scheduled_at)
);

-- Calls table
CREATE TABLE calls (
    id INT PRIMARY KEY AUTO_INCREMENT,
    activity_id INT,
    customer_id INT NOT NULL,
    user_id INT NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    direction ENUM('inbound', 'outbound') NOT NULL,
    duration INT, -- in seconds
    status ENUM('completed', 'missed', 'busy', 'no_answer') DEFAULT 'completed',
    recording_url TEXT,
    transcript LONGTEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (activity_id) REFERENCES activities(id) ON DELETE SET NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_calls_customer (customer_id),
    INDEX idx_calls_user (user_id),
    INDEX idx_calls_direction (direction),
    INDEX idx_calls_status (status)
);

-- Emails table
CREATE TABLE emails (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    user_id INT NOT NULL,
    subject VARCHAR(255) NOT NULL,
    body LONGTEXT NOT NULL,
    html_body LONGTEXT,
    direction ENUM('sent', 'received') NOT NULL,
    status ENUM('draft', 'sent', 'delivered', 'opened', 'clicked') DEFAULT 'sent',
    opened_at TIMESTAMP,
    clicked_at TIMESTAMP,
    template_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_emails_customer (customer_id),
    INDEX idx_emails_user (user_id),
    INDEX idx_emails_direction (direction),
    INDEX idx_emails_status (status)
);

-- Invoices table
CREATE TABLE invoices (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    deal_id INT,
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    subtotal DECIMAL(15,2) NOT NULL,
    tax_rate DECIMAL(5,2) DEFAULT 0.00,
    tax_amount DECIMAL(15,2) DEFAULT 0.00,
    total DECIMAL(15,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    status ENUM('draft', 'sent', 'paid', 'overdue', 'cancelled') DEFAULT 'draft',
    due_date DATE NOT NULL,
    paid_date DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    FOREIGN KEY (deal_id) REFERENCES deals(id) ON DELETE SET NULL,
    INDEX idx_invoices_customer (customer_id),
    INDEX idx_invoices_number (invoice_number),
    INDEX idx_invoices_status (status),
    INDEX idx_invoices_due_date (due_date)
);

-- Invoice items table
CREATE TABLE invoice_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    invoice_id INT NOT NULL,
    description VARCHAR(255) NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    total DECIMAL(15,2) NOT NULL,
    FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE,
    INDEX idx_invoice_items_invoice (invoice_id)
);

-- Email templates table
CREATE TABLE email_templates (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    subject VARCHAR(255) NOT NULL,
    body LONGTEXT NOT NULL,
    html_body LONGTEXT,
    category VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_templates_category (category),
    INDEX idx_templates_active (is_active)
);

-- Follow-ups table
CREATE TABLE follow_ups (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    type ENUM('call', 'email', 'meeting', 'task') NOT NULL,
    priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
    status ENUM('pending', 'completed', 'cancelled') DEFAULT 'pending',
    scheduled_at TIMESTAMP NOT NULL,
    completed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_followups_customer (customer_id),
    INDEX idx_followups_user (user_id),
    INDEX idx_followups_type (type),
    INDEX idx_followups_priority (priority),
    INDEX idx_followups_status (status),
    INDEX idx_followups_scheduled (scheduled_at)
);

-- Analytics events table
CREATE TABLE analytics_events (
    id INT PRIMARY KEY AUTO_INCREMENT,
    event_type VARCHAR(100) NOT NULL,
    user_id INT,
    customer_id INT,
    deal_id INT,
    metadata JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL,
    FOREIGN KEY (deal_id) REFERENCES deals(id) ON DELETE SET NULL,
    INDEX idx_analytics_event_type (event_type),
    INDEX idx_analytics_user (user_id),
    INDEX idx_analytics_customer (customer_id),
    INDEX idx_analytics_created (created_at)
);

-- Insert default admin user
INSERT INTO users (email, password_hash, first_name, last_name, role) VALUES
('admin@demo.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewNvZ7wSdckhRJOi', 'Admin', 'User', 'admin');

-- Insert demo user
INSERT INTO users (email, password_hash, first_name, last_name, role) VALUES  
('user@demo.com', '$2a$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Demo', 'User', 'user');

-- Insert sample customers
INSERT INTO customers (first_name, last_name, email, phone, company, customer_type, assigned_to) VALUES
('John', 'Smith', 'john.smith@email.com', '+1-555-0101', 'Acme Corp', 'customer', 1),
('Sarah', 'Johnson', 'sarah.j@techcorp.com', '+1-555-0102', 'Tech Corp', 'prospect', 1),
('Mike', 'Brown', 'mike.brown@startup.io', '+1-555-0103', 'Innovation Startup', 'lead', 2),
('Emily', 'Davis', 'emily.davis@enterprise.com', '+1-555-0104', 'Enterprise Solutions', 'customer', 1),
('James', 'Wilson', 'james.w@consulting.biz', '+1-555-0105', 'Wilson Consulting', 'prospect', 2);

-- Insert sample deals
INSERT INTO deals (customer_id, title, description, value, stage, probability, expected_close_date, assigned_to) VALUES
(1, 'Q4 Software License', 'Annual software license renewal', 50000.00, 'negotiation', 80, '2025-12-31', 1),
(2, 'Cloud Migration Project', 'Complete infrastructure migration to cloud', 125000.00, 'proposal', 60, '2026-02-15', 1),
(3, 'Startup Package', 'Complete business solution for startup', 25000.00, 'qualified', 45, '2026-01-30', 2),
(4, 'Enterprise Implementation', 'Large scale enterprise software implementation', 500000.00, 'closed_won', 100, '2025-11-30', 1),
(5, 'Consulting Services', 'Strategic business consulting engagement', 75000.00, 'prospect', 25, '2026-03-15', 2);

-- Insert sample activities
INSERT INTO activities (customer_id, user_id, type, title, description, status, scheduled_at) VALUES
(1, 1, 'call', 'Follow-up call', 'Discuss contract renewal terms', 'completed', '2025-08-28 10:00:00'),
(2, 1, 'email', 'Proposal sent', 'Sent cloud migration proposal', 'completed', '2025-08-27 14:30:00'),
(3, 2, 'meeting', 'Demo session', 'Product demonstration scheduled', 'pending', '2025-08-30 15:00:00'),
(4, 1, 'task', 'Contract preparation', 'Prepare enterprise implementation contract', 'pending', '2025-08-29 09:00:00'),
(5, 2, 'note', 'Client requirements', 'Documented consulting requirements', 'completed', '2025-08-26 11:00:00');

-- Insert sample email templates
INSERT INTO email_templates (name, subject, body, category, created_by) VALUES
('Welcome Email', 'Welcome to our CRM System', 'Dear {{firstName}},\n\nWelcome to our platform! We\'re excited to help you manage your business relationships.\n\nBest regards,\nThe Team', 'onboarding', 1),
('Follow-up', 'Following up on our conversation', 'Hi {{firstName}},\n\nI wanted to follow up on our recent conversation about {{topic}}.\n\nPlease let me know if you have any questions.\n\nBest regards,\n{{senderName}}', 'sales', 1),
('Invoice Reminder', 'Invoice Payment Reminder', 'Dear {{firstName}},\n\nThis is a friendly reminder that invoice #{{invoiceNumber}} is due on {{dueDate}}.\n\nThank you for your business!', 'billing', 1);

-- Insert sample follow-ups
INSERT INTO follow_ups (customer_id, user_id, title, description, type, priority, scheduled_at) VALUES
(1, 1, 'Contract renewal discussion', 'Call to discuss renewal terms and pricing', 'call', 'high', '2025-08-30 10:00:00'),
(2, 1, 'Proposal follow-up', 'Follow up on cloud migration proposal', 'email', 'medium', '2025-09-02 09:00:00'),
(3, 2, 'Demo preparation', 'Prepare demo materials for startup meeting', 'task', 'medium', '2025-08-29 16:00:00');

COMMIT;