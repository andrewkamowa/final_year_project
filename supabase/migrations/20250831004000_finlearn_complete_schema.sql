-- ========================
-- 1. ENUM TYPES
-- ========================
CREATE TYPE user_role AS ENUM ('admin', 'instructor', 'student');
CREATE TYPE course_status AS ENUM ('draft', 'published', 'archived');
CREATE TYPE content_type AS ENUM ('video', 'audio', 'text', 'quiz', 'interactive');
CREATE TYPE quiz_question_type AS ENUM ('multiple_choice', 'true_false', 'numerical');
CREATE TYPE enrollment_status AS ENUM ('active', 'completed', 'dropped');
CREATE TYPE difficulty_level AS ENUM ('Beginner', 'Intermediate', 'Advanced', 'Expert');
CREATE TYPE achievement_type AS ENUM ('completion', 'streak', 'points', 'special', 'milestone');

-- ========================
-- 2. CORE TABLES
-- ========================
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  bio TEXT,
  avatar_url TEXT,
  role user_role NOT NULL DEFAULT 'student',
  profile_image_url TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE instructors (
  id UUID PRIMARY KEY REFERENCES user_profiles(id) ON DELETE CASCADE,
  bio TEXT,
  expertise JSONB,
  rating NUMERIC(2,1) DEFAULT 0.0,
  total_students INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  instructor_id UUID REFERENCES instructors(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  hero_image TEXT,
  difficulty difficulty_level,
  duration_minutes INT,
  lesson_count INT DEFAULT 0,
  prerequisites JSONB,
  learning_points JSONB,
  status course_status DEFAULT 'draft',
  topics TEXT[],
  rating NUMERIC(2,1) DEFAULT 0.0,
  review_count INT DEFAULT 0,
  price NUMERIC(10,2) DEFAULT 0.0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE course_modules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  order_number INT NOT NULL,
  duration_minutes INT,
  content_type content_type NOT NULL,
  content_url TEXT,
  content_data JSONB,
  is_locked BOOLEAN DEFAULT false,
  prerequisites JSONB,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ========================
-- 3. QUIZZES & QUESTIONS
-- ========================
CREATE TABLE quizzes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  module_id UUID REFERENCES course_modules(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  time_limit_minutes INT,
  attempts_allowed INT DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE quiz_questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id UUID REFERENCES quizzes(id) ON DELETE CASCADE,
  question_text TEXT NOT NULL,
  question_type quiz_question_type NOT NULL,
  options JSONB,
  correct_answer TEXT,
  explanation TEXT,
  hint TEXT,
  concept_reference TEXT,
  points INT DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE quiz_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id UUID REFERENCES quizzes(id) ON DELETE CASCADE,
  user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
  score NUMERIC(5,2),
  answers JSONB,
  attempt_number INT DEFAULT 1,
  completed_at TIMESTAMPTZ DEFAULT now(),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ========================
-- 4. ENROLLMENTS & PROGRESS
-- ========================
CREATE TABLE enrollments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
  course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
  status enrollment_status DEFAULT 'active',
  progress NUMERIC(5,2) DEFAULT 0.0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE module_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
  module_id UUID REFERENCES course_modules(id) ON DELETE CASCADE,
  progress NUMERIC(5,2) DEFAULT 0.0,
  is_completed BOOLEAN DEFAULT false,
  time_spent_minutes INT DEFAULT 0,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, module_id)
);

-- ========================
-- 5. COMMUNITY (Reviews, Notes, Bookmarks)
-- ========================
CREATE TABLE course_reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
  user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
  rating INT CHECK (rating >= 1 AND rating <= 5),
  review_text TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  upvotes INT DEFAULT 0,
  downvotes INT DEFAULT 0
);

CREATE TABLE user_notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
  module_id UUID REFERENCES course_modules(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  timestamp_in_content TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE course_bookmarks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
  course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, course_id)
);

-- ========================
-- 6. GAMIFICATION
-- ========================
CREATE TABLE user_stats (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
  courses_completed INT DEFAULT 0,
  points_earned INT DEFAULT 0,
  streak_days INT DEFAULT 0,
  quizzes_completed INT DEFAULT 0,
  avg_quiz_score NUMERIC(5,2) DEFAULT 0.0,
  certificates_earned INT DEFAULT 0,
  last_active TIMESTAMPTZ DEFAULT now(),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE achievements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  type achievement_type NOT NULL,
  points_reward INT DEFAULT 0,
  icon_url TEXT,
  earned_date TIMESTAMPTZ DEFAULT now(),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ========================
-- 7. RLS POLICIES
-- ========================
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE instructors ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE quizzes ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE module_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_bookmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;

-- Example: Allow users to read/write their own profile
CREATE POLICY "Users can view their own profile"
  ON user_profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON user_profiles FOR UPDATE
  USING (auth.uid() = id);

-- (Add similar instructor/course/enrollment/module policies as needed)

-- ========================
-- 8. MOCK DATA (safe to remove later)
-- ========================
-- 👤 Users
INSERT INTO auth.users (id, email)
VALUES
  ('00000000-0000-0000-0000-000000000001', 'admin@example.com'),
  ('00000000-0000-0000-0000-000000000002', 'instructor@example.com'),
  ('00000000-0000-0000-0000-000000000003', 'student1@example.com'),
  ('00000000-0000-0000-0000-000000000004', 'student2@example.com');

INSERT INTO user_profiles (id, email, full_name, role)
VALUES
  ('00000000-0000-0000-0000-000000000001', 'admin@example.com', 'Admin User', 'admin'),
  ('00000000-0000-0000-0000-000000000002', 'instructor@example.com', 'Instructor One', 'instructor'),
  ('00000000-0000-0000-0000-000000000003', 'student1@example.com', 'Student One', 'student'),
  ('00000000-0000-0000-0000-000000000004', 'student2@example.com', 'Student Two', 'student');

INSERT INTO instructors (id, bio, expertise, rating, total_students)
VALUES
  ('00000000-0000-0000-0000-000000000002',
   'Expert in finance and investments',
   '["Finance", "Investments"]',
   4.8,
   0);

-- 🎓 Course + Modules
INSERT INTO courses (id, instructor_id, title, description, difficulty, duration_minutes, status, topics)
VALUES
  ('10000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   'Financial Basics 101',
   'Learn the fundamentals of personal finance and budgeting.',
   'Beginner',
   90,
   'published',
   ARRAY['Budgeting','Saving','Investing']);

INSERT INTO course_modules (id, course_id, title, description, order_number, duration_minutes, content_type, content_url)
VALUES
  ('20000000-0000-0000-0000-000000000001',
   '10000000-0000-0000-0000-000000000001',
   'Introduction to Budgeting',
   'A short video on how to create a personal budget.',
   1,
   30,
   'video',
   'https://example.com/intro.mp4'),
  ('20000000-0000-0000-0000-000000000002',
   '10000000-0000-0000-0000-000000000001',
   'Budgeting Quiz',
   'Test your knowledge on budgeting basics.',
   2,
   15,
   'quiz',
   NULL);

-- 📝 Quiz & Questions
INSERT INTO quizzes (id, module_id, title, description, time_limit_minutes)
VALUES
  ('30000000-0000-0000-0000-000000000001',
   '20000000-0000-0000-0000-000000000002',
   'Budgeting Basics Quiz',
   'Check your understanding of budgeting principles.',
   10);

INSERT INTO quiz_questions (id, quiz_id, question_text, question_type, options, correct_answer, explanation, points)
VALUES
  ('40000000-0000-0000-0000-000000000001',
   '30000000-0000-0000-0000-000000000001',
   'What is the main purpose of a personal budget?',
   'multiple_choice',
   '["Track expenses","Increase debt","Ignore savings"]',
   'Track expenses',
   'A budget helps you track and control your spending.',
   2),
  ('40000000-0000-0000-0000-000000000002',
   '30000000-0000-0000-0000-000000000001',
   'True or False: Budgeting prevents all unexpected expenses.',
   'true_false',
   '["True","False"]',
   'False',
   'Budgets help prepare for unexpected expenses but can’t prevent them.',
   1);

-- 📚 Enrollments + Progress
INSERT INTO enrollments (id, user_id, course_id, status, progress)
VALUES
  ('50000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000003',
   '10000000-0000-0000-0000-000000000001',
   'active',
   40.0),
  ('50000000-0000-0000-0000-000000000002',
   '00000000-0000-0000-0000-000000000004',
   '10000000-0000-0000-0000-000000000001',
   'active',
   20.0);

INSERT INTO module_progress (id, user_id, module_id, progress, is_completed, time_spent_minutes)
VALUES
  ('60000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000003',
   '20000000-0000-0000-0000-000000000001',
   100.0,
   true,
   30);

-- ⭐ Reviews + Notes
INSERT INTO course_reviews (id, course_id, user_id, rating, review_text)
VALUES
  ('70000000-0000-0000-0000-000000000001',
   '10000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000003',
   5,
   'Great introduction to budgeting! Clear and practical.');

INSERT INTO user_notes (id, user_id, module_id, content, timestamp_in_content)
VALUES
  ('80000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000003',
   '20000000-0000-0000-0000-000000000001',
   'Remember to track rent and food first.',
   '00:02:15');

-- 🏆 Gamification
INSERT INTO user_stats (id, user_id, courses_completed, points_earned, streak_days, quizzes_completed, avg_quiz_score, certificates_earned)
VALUES
  ('90000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000003',
   1, 120, 5, 2, 85.0, 1);

INSERT INTO achievements (id, user_id, title, description, type, points_reward, icon_url)
VALUES
  ('a0000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000003',
   'First Steps',
   'Completed your first course!',
   'completion',
   50,
   'https://example.com/first_steps.png');
