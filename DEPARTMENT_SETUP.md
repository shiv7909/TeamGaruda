# Department Authentication Setup

This guide will help you set up the department authentication system for your ThirdEye Admin app.

## Database Setup

1. **Create departments table**:
   - Open your Supabase dashboard
   - Go to SQL Editor
   - Copy and paste the contents of `setup_departments.sql`
   - Run the SQL script

2. **Add department field to issues table**:
   - Copy and paste the contents of `add_department_to_issues.sql`
   - Run the SQL script

This will:
- Create the `departments` table with proper schema and RLS policies
- Add a `department` field to the `issues` table for assigning issues to departments

## Adding Departments

After running the SQL scripts, you need to add department records to the departments table. You can do this through:

1. **Supabase Dashboard**: Go to Table Editor → departments → Insert
2. **SQL Query**:
   ```sql
   INSERT INTO public.departments (department, mail, pass)
   VALUES ('Your Department Name', 'email@domain.com', 'your-password');
   ```

## Assigning Issues to Departments

To assign issues to departments, update the department field in the issues table:

### Option 1: Manual Assignment
```sql
UPDATE public.issues SET department = 'Water Supply & Sewerage' WHERE id = 'your-issue-id';
```

### Option 2: Bulk Assignment by Keywords
Run the `assign_issues_to_department.sql` script to automatically assign issues based on keywords in titles and categories.

### Option 3: Through Supabase Dashboard
1. Go to Table Editor → issues
2. Find the issue you want to assign
3. Edit the `department` field and set it to the department name

## Testing Department-Specific Issues

1. Login with department credentials (e.g., `water@sentinel.com`)
2. The profile page will now show only issues assigned to that department
3. Issues will display with department information in the issue cards

## Security Notes

- The scripts enable Row Level Security (RLS) on the tables
- Anonymous read/insert policies are created for testing
- In production, you should adjust these policies based on your security requirements
- Consider hashing passwords instead of storing them in plain text

## Troubleshooting

If login fails:
1. Check that the tables were created successfully in Supabase
2. Verify you have added department records to the departments table
3. Check your Supabase URL and anon key in the app
4. Look at the console output for any error messages

If issues don't show up:
1. Make sure issues have the department field set
2. Check that the department name matches exactly (case-sensitive)
3. Verify the issues table has the department column added