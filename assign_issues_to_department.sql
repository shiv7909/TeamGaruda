-- Assign sample issues to the Water Supply & Sewerage department
-- This script assigns some existing issues to the department for testing

-- First, let's see what issues exist
-- SELECT id, title, department FROM public.issues LIMIT 5;

-- Assign a few issues to the Water Supply & Sewerage department
-- Replace the issue IDs below with actual issue IDs from your database

-- Example assignments (uncomment and modify with real issue IDs):
-- UPDATE public.issues SET department = 'Water Supply & Sewerage' WHERE id = 'your-issue-id-1';
-- UPDATE public.issues SET department = 'Water Supply & Sewerage' WHERE id = 'your-issue-id-2';
-- UPDATE public.issues SET department = 'Water Supply & Sewerage' WHERE id = 'your-issue-id-3';

-- To assign all issues with certain keywords to the department:
UPDATE public.issues
SET department = 'Water Supply & Sewerage'
WHERE (title ILIKE '%water%' OR title ILIKE '%sewer%' OR title ILIKE '%pipe%' OR title ILIKE '%leak%')
AND department IS NULL;

-- To assign issues by category:
UPDATE public.issues
SET department = 'Water Supply & Sewerage'
WHERE issue_type ILIKE '%water%' OR issue_type ILIKE '%sewer%'
AND department IS NULL;

-- Check how many issues are now assigned to the department
-- SELECT COUNT(*) as water_department_issues FROM public.issues WHERE department = 'Water Supply & Sewerage';