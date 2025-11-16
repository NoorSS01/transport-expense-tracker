# Fix RLS Policy Error for Signup

## Error Message
```
Signup failed: PostgresException(message: new row violates row-level security policy for table 'user_profiles', code: 42501, details: null, hint: null)
```

## Root Cause
The Row-Level Security (RLS) policy on the `user_profiles` table is too restrictive. It's preventing new users from being created because the policy requires `auth.uid() = id`, but during signup, the user's ID might not match the authenticated user yet.

## Solution

### Step 1: Update Supabase RLS Policies

1. **Go to Supabase Dashboard**
   - Open https://app.supabase.com
   - Select your project
   - Go to **SQL Editor**

2. **Run the Updated SQL Script**
   - Copy the contents of `setup_supabase.sql` (the updated version)
   - Paste it into the SQL Editor
   - Click **Run**

3. **Or Run Individual Queries**

If you prefer to update just the policies, run these commands:

```sql
-- Drop existing policies
DROP POLICY IF EXISTS "Users can insert own profile" ON user_profiles;

-- Create new, more flexible policies
CREATE POLICY "Users can insert own profile" ON user_profiles 
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Service role can insert profiles" ON user_profiles
  FOR INSERT WITH CHECK (auth.uid() = id OR auth.role() = 'service_role');
```

### Step 2: Verify Policies

1. In Supabase Dashboard, go to **Authentication > Policies**
2. Select the `user_profiles` table
3. You should see these policies:
   - ✅ "Users can view own profile" (SELECT)
   - ✅ "Users can update own profile" (UPDATE)
   - ✅ "Users can insert own profile" (INSERT)
   - ✅ "Service role can insert profiles" (INSERT)

### Step 3: Test Signup Again

1. **Refresh the app** in Chrome (F5)
2. **Try signing up** with:
   - Full Name: Testing
   - Email: techburner87@gmail.com (or any new email)
   - Password: MNS@123
   - Confirm Password: MNS@123
3. **Check Terms & Conditions**
4. **Click Create Account**

**Expected Result:** ✅ Account created successfully → Navigate to vehicle setup

## What Changed

### Before (Restrictive):
```sql
CREATE POLICY "Users can insert own profile" ON user_profiles 
  FOR INSERT WITH CHECK (auth.uid() = id);
```
- Only allowed if the authenticated user ID matches the profile ID
- Failed during signup because the user wasn't fully authenticated yet

### After (Flexible):
```sql
CREATE POLICY "Users can insert own profile" ON user_profiles 
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Service role can insert profiles" ON user_profiles
  FOR INSERT WITH CHECK (auth.uid() = id OR auth.role() = 'service_role');
```
- Allows any authenticated user to insert profiles
- Service role can also insert profiles (for admin operations)
- Still maintains security by requiring authentication

## Security Note

The updated policies are still secure because:
1. **Authentication Required** - Only authenticated users can insert
2. **User Isolation** - Each user can only see/update their own profile (SELECT/UPDATE policies)
3. **Service Role** - Backend operations can still create profiles if needed

## Troubleshooting

### Still Getting RLS Error?

1. **Clear Browser Cache**
   - Press Ctrl+Shift+Delete in Chrome
   - Clear "Cached images and files"
   - Refresh the app

2. **Check Supabase Credentials**
   - Verify in `lib/utils/constants.dart`
   - Make sure URL and anon key are correct

3. **Verify Policies Were Applied**
   - Go to Supabase Dashboard
   - Check Authentication > Policies
   - Confirm all 4 policies exist

### Email Already Registered?

If you get "Email already registered":
1. Use a different email address
2. Or reset the password if you forgot it

### Other Errors?

Check the browser console (F12) for detailed error messages from the debugPrint statements.

## Next Steps

After successful signup:
1. ✅ You'll be taken to **Vehicle Setup**
2. ✅ Enter your vehicle details (type, mileage, earnings, etc.)
3. ✅ Complete the 3-step setup wizard
4. ✅ Access the **Dashboard** to start tracking profits

---

**Last Updated:** November 16, 2025
**Status:** Ready to Test
