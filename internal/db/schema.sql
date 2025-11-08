-- Users Table
CREATE TYPE user_type_enum AS ENUM ('client', 'freelancer', 'both');
CREATE TYPE status_enum AS ENUM ('active', 'suspended', 'deactivated');

CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    profile_image_url VARCHAR(500),
    user_type user_type_enum NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE,
    email_verified BOOLEAN DEFAULT FALSE,
    phone_verified BOOLEAN DEFAULT FALSE,
    status status_enum DEFAULT 'active',
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    last_login TIMESTAMPTZ,
    timezone VARCHAR(50) DEFAULT 'UTC'
);

-- User Profiles Table
CREATE TYPE experience_level_enum AS ENUM ('beginner', 'intermediate', 'expert');
CREATE TYPE availability_enum AS ENUM ('full_time', 'part_time', 'as_needed');

CREATE TABLE user_profiles (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    bio TEXT,
    hourly_rate NUMERIC(10,2),
    experience_level experience_level_enum,
    availability availability_enum,
    location_address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    zip_code VARCHAR(20),
    country VARCHAR(100),
    latitude NUMERIC(10,8),
    longitude NUMERIC(11,8),
    service_radius INT DEFAULT 10,
    languages JSONB,
    website_url VARCHAR(500),
    linkedin_url VARCHAR(500),
    facebook_url VARCHAR(500),
    instagram_url VARCHAR(500),
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Categories Table
CREATE TABLE categories (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon_url VARCHAR(500),
    parent_id BIGINT REFERENCES categories(id) ON DELETE CASCADE,
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Skills Table
CREATE TABLE skills (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    category_id BIGINT REFERENCES categories(id) ON DELETE SET NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- User Skills Table
CREATE TYPE proficiency_level_enum AS ENUM ('beginner', 'intermediate', 'advanced', 'expert');

CREATE TABLE user_skills (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    skill_id BIGINT NOT NULL REFERENCES skills(id) ON DELETE CASCADE,
    proficiency_level proficiency_level_enum,
    years_of_experience INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(user_id, skill_id)
);

-- Jobs Table
CREATE TYPE budget_type_enum AS ENUM ('fixed', 'hourly');
CREATE TYPE project_duration_enum AS ENUM ('less_than_week', '1_to_4_weeks', '1_to_3_months', '3_to_6_months', 'more_than_6_months');
CREATE TYPE urgency_enum AS ENUM ('low', 'medium', 'high', 'urgent');
CREATE TYPE location_type_enum AS ENUM ('remote', 'on_site', 'hybrid');
CREATE TYPE job_status_enum AS ENUM ('draft', 'open', 'in_progress', 'completed', 'cancelled', 'paused');
CREATE TYPE visibility_enum AS ENUM ('public', 'private', 'invited_only');

CREATE TABLE jobs (
    id BIGSERIAL PRIMARY KEY,
    client_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category_id BIGINT REFERENCES categories(id) ON DELETE SET NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    requirements TEXT,
    budget_type budget_type_enum NOT NULL,
    budget_min NUMERIC(10,2),
    budget_max NUMERIC(10,2),
    hourly_rate_min NUMERIC(10,2),
    hourly_rate_max NUMERIC(10,2),
    estimated_hours INT,
    project_duration project_duration_enum,
    urgency urgency_enum DEFAULT 'medium',
    location_type location_type_enum NOT NULL,
    job_address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    zip_code VARCHAR(20),
    country VARCHAR(100),
    latitude NUMERIC(10,8),
    longitude NUMERIC(11,8),
    preferred_start_date DATE,
    deadline DATE,
    status job_status_enum DEFAULT 'open',
    visibility visibility_enum DEFAULT 'public',
    applications_count INT DEFAULT 0,
    views_count INT DEFAULT 0,
    is_featured BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    published_at TIMESTAMPTZ,
    closed_at TIMESTAMPTZ
);

-- Job Skills Table
CREATE TABLE job_skills (
    id BIGSERIAL PRIMARY KEY,
    job_id BIGINT NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
    skill_id BIGINT NOT NULL REFERENCES skills(id) ON DELETE CASCADE,
    is_required BOOLEAN DEFAULT TRUE,
    proficiency_level proficiency_level_enum,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Job Attachments Table
CREATE TABLE job_attachments (
    id BIGSERIAL PRIMARY KEY,
    job_id BIGINT NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size INT NOT NULL,
    file_type VARCHAR(100),
    uploaded_by BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Proposals Table
CREATE TYPE proposal_status_enum AS ENUM ('pending', 'shortlisted', 'accepted', 'rejected', 'withdrawn');
CREATE TYPE rate_type_enum AS ENUM ('fixed', 'hourly');

CREATE TABLE proposals (
    id BIGSERIAL PRIMARY KEY,
    job_id BIGINT NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
    freelancer_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    cover_letter TEXT NOT NULL,
    proposed_rate NUMERIC(10,2) NOT NULL,
    rate_type rate_type_enum NOT NULL,
    estimated_hours INT,
    delivery_time INT,
    availability_start_date DATE,
    status proposal_status_enum DEFAULT 'pending',
    is_featured BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    responded_at TIMESTAMPTZ,
    UNIQUE(job_id, freelancer_id)
);

-- Proposal Attachments Table
CREATE TABLE proposal_attachments (
    id BIGSERIAL PRIMARY KEY,
    proposal_id BIGINT NOT NULL REFERENCES proposals(id) ON DELETE CASCADE,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size INT NOT NULL,
    file_type VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Contracts Table
CREATE TYPE contract_status_enum AS ENUM ('pending', 'active', 'completed', 'cancelled', 'disputed', 'paused');
CREATE TYPE payment_terms_enum AS ENUM ('milestone', 'hourly', 'completion', 'weekly');

CREATE TABLE contracts (
    id BIGSERIAL PRIMARY KEY,
    job_id BIGINT NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
    client_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    freelancer_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    proposal_id BIGINT REFERENCES proposals(id) ON DELETE SET NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    contract_type rate_type_enum NOT NULL,
    total_amount NUMERIC(10,2),
    hourly_rate NUMERIC(10,2),
    estimated_hours INT,
    start_date DATE,
    end_date DATE,
    status contract_status_enum DEFAULT 'pending',
    terms_and_conditions TEXT,
    payment_terms payment_terms_enum DEFAULT 'completion',
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    signed_by_client_at TIMESTAMPTZ,
    signed_by_freelancer_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ
);

-- Milestones Table
CREATE TYPE milestone_status_enum AS ENUM ('pending', 'submitted', 'approved', 'rejected', 'paid');

CREATE TABLE milestones (
    id BIGSERIAL PRIMARY KEY,
    contract_id BIGINT NOT NULL REFERENCES contracts(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    amount NUMERIC(10,2) NOT NULL,
    due_date DATE,
    status milestone_status_enum DEFAULT 'pending',
    order_index INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    submitted_at TIMESTAMPTZ,
    approved_at TIMESTAMPTZ,
    paid_at TIMESTAMPTZ
);

-- Time Logs Table
CREATE TYPE time_log_status_enum AS ENUM ('running', 'stopped', 'approved', 'rejected');

CREATE TABLE time_logs (
    id BIGSERIAL PRIMARY KEY,
    contract_id BIGINT NOT NULL REFERENCES contracts(id) ON DELETE CASCADE,
    freelancer_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    description TEXT,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ,
    hours_logged NUMERIC(8,2),
    hourly_rate NUMERIC(10,2),
    total_amount NUMERIC(10,2),
    status time_log_status_enum DEFAULT 'stopped',
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Transactions Table
CREATE TYPE transaction_type_enum AS ENUM ('payment', 'refund', 'bonus', 'penalty');
CREATE TYPE payment_method_enum AS ENUM ('credit_card', 'paypal', 'bank_transfer', 'wallet');
CREATE TYPE transaction_status_enum AS ENUM ('pending', 'processing', 'completed', 'failed', 'cancelled', 'refunded');

CREATE TABLE transactions (
    id BIGSERIAL PRIMARY KEY,
    contract_id BIGINT REFERENCES contracts(id) ON DELETE SET NULL,
    milestone_id BIGINT REFERENCES milestones(id) ON DELETE SET NULL,
    payer_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    payee_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    amount NUMERIC(10,2) NOT NULL,
    platform_fee NUMERIC(10,2) DEFAULT 0,
    net_amount NUMERIC(10,2) NOT NULL,
    transaction_type transaction_type_enum DEFAULT 'payment',
    payment_method payment_method_enum NOT NULL,
    payment_gateway VARCHAR(50),
    gateway_transaction_id VARCHAR(255),
    status transaction_status_enum DEFAULT 'pending',
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    processed_at TIMESTAMPTZ
);

-- User Wallets Table
CREATE TABLE user_wallets (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    balance NUMERIC(10,2) DEFAULT 0.00,
    pending_balance NUMERIC(10,2) DEFAULT 0.00,
    total_earned NUMERIC(10,2) DEFAULT 0.00,
    total_spent NUMERIC(10,2) DEFAULT 0.00,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Messages Table
CREATE TYPE message_type_enum AS ENUM ('text', 'file', 'image', 'system');

CREATE TABLE messages (
    id BIGSERIAL PRIMARY KEY,
    contract_id BIGINT REFERENCES contracts(id) ON DELETE CASCADE,
    job_id BIGINT REFERENCES jobs(id) ON DELETE CASCADE,
    sender_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    recipient_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    subject VARCHAR(255),
    message TEXT NOT NULL,
    message_type message_type_enum DEFAULT 'text',
    is_read BOOLEAN DEFAULT FALSE,
    parent_message_id BIGINT REFERENCES messages(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    read_at TIMESTAMPTZ
);

-- Message Attachments Table
CREATE TABLE message_attachments (
    id BIGSERIAL PRIMARY KEY,
    message_id BIGINT NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size INT NOT NULL,
    file_type VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Reviews Table
CREATE TYPE review_status_enum AS ENUM ('pending', 'published', 'disputed', 'removed');

CREATE TABLE reviews (
    id BIGSERIAL PRIMARY KEY,
    contract_id BIGINT NOT NULL REFERENCES contracts(id) ON DELETE CASCADE,
    reviewer_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reviewee_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    communication_rating INT CHECK (communication_rating >= 1 AND communication_rating <= 5),
    quality_rating INT CHECK (quality_rating >= 1 AND quality_rating <= 5),
    timeliness_rating INT CHECK (timeliness_rating >= 1 AND timeliness_rating <= 5),
    professionalism_rating INT CHECK (professionalism_rating >= 1 AND professionalism_rating <= 5),
    would_recommend BOOLEAN DEFAULT TRUE,
    is_public BOOLEAN DEFAULT TRUE,
    status review_status_enum DEFAULT 'published',
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(contract_id, reviewer_id)
);

-- Notifications Table
CREATE TYPE notification_type_enum AS ENUM (
    'job_posted', 'proposal_received', 'proposal_accepted', 'proposal_rejected',
    'contract_signed', 'milestone_submitted', 'milestone_approved',
    'payment_received', 'review_received', 'message_received', 'system'
);

CREATE TABLE notifications (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type notification_type_enum NOT NULL,
    related_entity_type VARCHAR(50),
    related_entity_id BIGINT,
    is_read BOOLEAN DEFAULT FALSE,
    is_email_sent BOOLEAN DEFAULT FALSE,
    is_push_sent BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT now(),
    read_at TIMESTAMPTZ
);

-- User Notification Settings Table
CREATE TABLE user_notification_settings (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    email_job_posted BOOLEAN DEFAULT TRUE,
    email_proposal_received BOOLEAN DEFAULT TRUE,
    email_proposal_status BOOLEAN DEFAULT TRUE,
    email_contract_updates BOOLEAN DEFAULT TRUE,
    email_payment_updates BOOLEAN DEFAULT TRUE,
    email_messages BOOLEAN DEFAULT TRUE,
    email_reviews BOOLEAN DEFAULT TRUE,
    push_job_posted BOOLEAN DEFAULT TRUE,
    push_proposal_received BOOLEAN DEFAULT TRUE,
    push_proposal_status BOOLEAN DEFAULT TRUE,
    push_contract_updates BOOLEAN DEFAULT TRUE,
    push_payment_updates BOOLEAN DEFAULT TRUE,
    push_messages BOOLEAN DEFAULT TRUE,
    push_reviews BOOLEAN DEFAULT TRUE,
    sms_important_updates BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Saved Jobs Table
CREATE TABLE saved_jobs (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    job_id BIGINT NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(user_id, job_id)
);

-- Job Views Table
CREATE TABLE job_views (
    id BIGSERIAL PRIMARY KEY,
    job_id BIGINT NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
    user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    viewed_at TIMESTAMPTZ DEFAULT now()
);

-- User Portfolios Table
CREATE TABLE user_portfolios (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    project_url VARCHAR(500),
    image_url VARCHAR(500),
    completion_date DATE,
    skills JSONB,
    is_featured BOOLEAN DEFAULT FALSE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Disputes Table
CREATE TYPE dispute_type_enum AS ENUM ('payment', 'quality', 'communication', 'scope', 'other');
CREATE TYPE dispute_status_enum AS ENUM ('open', 'in_review', 'resolved', 'closed');

CREATE TABLE disputes (
    id BIGSERIAL PRIMARY KEY,
    contract_id BIGINT NOT NULL REFERENCES contracts(id) ON DELETE CASCADE,
    raised_by BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    dispute_type dispute_type_enum NOT NULL,
    subject VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    amount_disputed NUMERIC(10,2),
    status dispute_status_enum DEFAULT 'open',
    resolution TEXT,
    resolved_by BIGINT REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    resolved_at TIMESTAMPTZ
);

-- Indexes for Performance --

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_user_type ON users(user_type);
CREATE INDEX idx_users_status ON users(status);

CREATE INDEX idx_jobs_client_id ON jobs(client_id);
CREATE INDEX idx_jobs_category_id ON jobs(category_id);
CREATE INDEX idx_jobs_status ON jobs(status);
CREATE INDEX idx_jobs_location ON jobs(city, state, country);
CREATE INDEX idx_jobs_budget ON jobs(budget_min, budget_max);
CREATE INDEX idx_jobs_created_at ON jobs(created_at);
CREATE INDEX idx_jobs_location_coords ON jobs(latitude, longitude);

CREATE INDEX idx_proposals_job_id ON proposals(job_id);
CREATE INDEX idx_proposals_freelancer_id ON proposals(freelancer_id);
CREATE INDEX idx_proposals_status ON proposals(status);
CREATE INDEX idx_proposals_created_at ON proposals(created_at);

CREATE INDEX idx_contracts_client_id ON contracts(client_id);
CREATE INDEX idx_contracts_freelancer_id ON contracts(freelancer_id);
CREATE INDEX idx_contracts_status ON contracts(status);

CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_recipient_id ON messages(recipient_id);
CREATE INDEX idx_messages_created_at ON messages(created_at);
CREATE INDEX idx_messages_is_read ON messages(is_read);

CREATE INDEX idx_reviews_reviewee_id ON reviews(reviewee_id);
CREATE INDEX idx_reviews_rating ON reviews(rating);
CREATE INDEX idx_reviews_created_at ON reviews(created_at);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at);
