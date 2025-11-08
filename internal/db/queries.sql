-- Users Queries

-- name: GetUserByID :one
SELECT * FROM users WHERE id = $1;

-- name: GetUserByEmail :one
SELECT * FROM users WHERE email = $1;

-- name: CreateUser :one
INSERT INTO users (email, password_hash, first_name, last_name, user_type, timezone, status)
VALUES ($1, $2, $3, $4, $5, $6, $7)
RETURNING *;

-- name: UpdateUser :one
UPDATE users
SET first_name = $2, last_name = $3, phone = $4, profile_image_url = $5,
    user_type = $6, is_verified = $7, email_verified = $8, phone_verified = $9,
    status = $10, updated_at = now()
WHERE id = $1
RETURNING *;

-- name: DeleteUser :exec
DELETE FROM users WHERE id = $1;

-- User Profiles Queries

-- name: GetUserProfileByUserID :one
SELECT * FROM user_profiles WHERE user_id = $1;

-- name: CreateUserProfile :one
INSERT INTO user_profiles (user_id, bio, hourly_rate, experience_level, availability, location_address,
    city, state, zip_code, country, latitude, longitude, service_radius, languages, website_url,
    linkedin_url, facebook_url, instagram_url)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18)
RETURNING *;

-- name: UpdateUserProfile :one
UPDATE user_profiles
SET bio = $2, hourly_rate = $3, experience_level = $4, availability = $5, location_address = $6,
    city = $7, state = $8, zip_code = $9, country = $10, latitude = $11, longitude = $12,
    service_radius = $13, languages = $14, website_url = $15, linkedin_url = $16,
    facebook_url = $17, instagram_url = $18, updated_at = now()
WHERE user_id = $1
RETURNING *;

-- Categories Queries

-- name: ListActiveCategories :many
SELECT * FROM categories WHERE is_active = TRUE ORDER BY sort_order, name;

-- Skills Queries

-- name: ListSkillsByCategory :many
SELECT * FROM skills WHERE category_id = $1 AND is_active = TRUE ORDER BY name;

-- User Skills Queries

-- name: GetUserSkills :many
SELECT * FROM user_skills WHERE user_id = $1 ORDER BY proficiency_level DESC;

-- name: AddUserSkill :one
INSERT INTO user_skills (user_id, skill_id, proficiency_level, years_of_experience)
VALUES ($1, $2, $3, $4)
RETURNING *;

-- Jobs Queries

-- name: CreateJob :one
INSERT INTO jobs (client_id, category_id, title, description, requirements, budget_type,
    budget_min, budget_max, hourly_rate_min, hourly_rate_max, estimated_hours, project_duration,
    urgency, location_type, job_address, city, state, zip_code, country, latitude, longitude,
    preferred_start_date, deadline, visibility, status, is_featured)
VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24,$25,$26)
RETURNING *;

-- name: UpdateJobStatus :one
UPDATE jobs SET status = $2, updated_at = now() WHERE id = $1 RETURNING *;

-- name: ListOpenJobs :many
SELECT * FROM jobs WHERE status = 'open' ORDER BY created_at DESC LIMIT $1 OFFSET $2;

-- name: GetJobByID :one
SELECT * FROM jobs WHERE id = $1;

-- Job Skills Queries

-- name: AddJobSkill :one
INSERT INTO job_skills (job_id, skill_id, is_required, proficiency_level)
VALUES ($1, $2, $3, $4)
RETURNING *;

-- name: GetJobSkills :many
SELECT * FROM job_skills WHERE job_id = $1;

-- Proposals Queries

-- name: CreateProposal :one
INSERT INTO proposals (job_id, freelancer_id, cover_letter, proposed_rate, rate_type,
    estimated_hours, delivery_time, availability_start_date, status, is_featured)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
RETURNING *;

-- name: UpdateProposalStatus :one
UPDATE proposals SET status = $2, updated_at = now() WHERE id = $1 RETURNING *;

-- name: GetProposalsByJobID :many
SELECT * FROM proposals WHERE job_id = $1 ORDER BY created_at DESC;

-- Contracts Queries

-- name: CreateContract :one
INSERT INTO contracts (job_id, client_id, freelancer_id, proposal_id, title, description,
    contract_type, total_amount, hourly_rate, estimated_hours, start_date, end_date, status,
    terms_and_conditions, payment_terms)
VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15)
RETURNING *;

-- name: UpdateContractStatus :one
UPDATE contracts SET status = $2, updated_at = now() WHERE id = $1 RETURNING *;

-- Milestones Queries

-- name: CreateMilestone :one
INSERT INTO milestones (contract_id, title, description, amount, due_date, status, order_index)
VALUES ($1,$2,$3,$4,$5,$6,$7)
RETURNING *;

-- Time Logs Queries

-- name: CreateTimeLog :one
INSERT INTO time_logs (contract_id, freelancer_id, description, start_time, end_time, hours_logged,
    hourly_rate, total_amount, status)
VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
RETURNING *;

-- name: UpdateTimeLogStatus :one
UPDATE time_logs SET status = $2, updated_at = now() WHERE id = $1 RETURNING *;

-- Transactions Queries

-- name: RecordTransaction :one
INSERT INTO transactions (contract_id, milestone_id, payer_id, payee_id, amount, platform_fee,
    net_amount, transaction_type, payment_method, payment_gateway, gateway_transaction_id, status,
    description, processed_at)
VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)
RETURNING *;

-- Messages Queries

-- name: SendMessage :one
INSERT INTO messages (contract_id, job_id, sender_id, recipient_id, subject, message, message_type)
VALUES ($1,$2,$3,$4,$5,$6,$7)
RETURNING *;

-- name: MarkMessageRead :exec
UPDATE messages SET is_read = TRUE, read_at = now() WHERE id = $1;

-- Reviews Queries

-- name: CreateReview :one
INSERT INTO reviews (contract_id, reviewer_id, reviewee_id, rating, review_text, communication_rating,
    quality_rating, timeliness_rating, professionalism_rating, would_recommend, is_public, status)
VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)
RETURNING *;

-- Notifications Queries

-- name: CreateNotification :one
INSERT INTO notifications (user_id, title, message, type, related_entity_type, related_entity_id)
VALUES ($1,$2,$3,$4,$5,$6)
RETURNING *;

-- name: MarkNotificationRead :exec
UPDATE notifications SET is_read = TRUE, read_at = now() WHERE id = $1;

-- User Notification Settings Queries

-- name: GetUserNotificationSettings :one
SELECT * FROM user_notification_settings WHERE user_id = $1;

-- name: UpdateUserNotificationSettings :one
UPDATE user_notification_settings
SET email_job_posted = $2, email_proposal_received = $3, email_proposal_status = $4,
    email_contract_updates = $5, email_payment_updates = $6, email_messages = $7,
    email_reviews = $8, push_job_posted = $9, push_proposal_received = $10, push_proposal_status = $11,
    push_contract_updates = $12, push_payment_updates = $13, push_messages = $14, push_reviews = $15,
    sms_important_updates = $16, updated_at = now()
WHERE user_id = $1
RETURNING *;

-- Saved Jobs Queries

-- name: SaveJob :exec
INSERT INTO saved_jobs (user_id, job_id) VALUES ($1, $2) ON CONFLICT DO NOTHING;

-- name: RemoveSavedJob :exec
DELETE FROM saved_jobs WHERE user_id = $1 AND job_id = $2;

-- name: ListSavedJobsForUser :many
SELECT * FROM saved_jobs WHERE user_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3;

-- Job Views Queries

-- name: RecordJobView :exec
INSERT INTO job_views (job_id, user_id, ip_address, user_agent) VALUES ($1, $2, $3, $4);

-- User Portfolios Queries

-- name: CreateUserPortfolio :one
INSERT INTO user_portfolios (user_id, title, description, project_url, image_url, completion_date,
    skills, is_featured, sort_order)
VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
RETURNING *;

-- Disputes Queries

-- name: CreateDispute :one
INSERT INTO disputes (contract_id, raised_by, dispute_type, subject, description, amount_disputed, status)
VALUES ($1,$2,$3,$4,$5,$6,$7)
RETURNING *;

-- name: UpdateDisputeStatus :one
UPDATE disputes SET status = $2, resolution = $3, resolved_by = $4, updated_at = now(), resolved_at = $5
WHERE id = $1
RETURNING *;
