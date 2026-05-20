'use client';
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import toast from 'react-hot-toast';
import { api, setAuth } from '@/lib/api';

export default function SignupPage() {
  const router = useRouter();
  const [form, setForm] = useState({ name: '', email: '', phone: '', orgName: '', password: '' });
  const [loading, setLoading] = useState(false);

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      const { data } = await api.post('/auth/register', form);
      setAuth(data.token, data.user);
      toast.success('Account created! 7-day free trial activated.');
      router.push('/dashboard');
    } catch (e: any) {
      toast.error(e.response?.data?.message || 'Signup failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <main className="min-h-screen flex items-center justify-center bg-fildbg p-4">
      <div className="w-full max-w-md card">
        <Link href="/" className="flex items-center gap-2 mb-6 justify-center">
          <div className="w-10 h-10 rounded-lg bg-primary text-white font-bold flex items-center justify-center">M</div>
          <span className="font-bold text-xl">MeetLead Pro</span>
        </Link>
        <h1 className="text-2xl font-bold text-center mb-1">Start your free trial</h1>
        <p className="text-textgrey text-center mb-6 text-sm">7 days free. No credit card needed.</p>

        <form onSubmit={submit} className="space-y-4">
          <div>
            <label className="label">Full name</label>
            <input required className="input" value={form.name}
              onChange={(e) => setForm({ ...form, name: e.target.value })} />
          </div>
          <div>
            <label className="label">Business / Workspace name</label>
            <input className="input" value={form.orgName}
              onChange={(e) => setForm({ ...form, orgName: e.target.value })} placeholder="(optional)" />
          </div>
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="label">Email</label>
              <input type="email" required className="input" value={form.email}
                onChange={(e) => setForm({ ...form, email: e.target.value })} />
            </div>
            <div>
              <label className="label">Phone</label>
              <input className="input" value={form.phone}
                onChange={(e) => setForm({ ...form, phone: e.target.value })} />
            </div>
          </div>
          <div>
            <label className="label">Password</label>
            <input type="password" required minLength={6} className="input" value={form.password}
              onChange={(e) => setForm({ ...form, password: e.target.value })} />
          </div>
          <button disabled={loading} className="btn-primary w-full">
            {loading ? 'Creating account...' : 'Create account & Start Trial'}
          </button>
        </form>

        <p className="text-sm text-center text-textgrey mt-6">
          Already have an account?{' '}
          <Link href="/login" className="text-primary font-medium">Sign in</Link>
        </p>
      </div>
    </main>
  );
}
