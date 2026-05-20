'use client';
import { useEffect, useState } from 'react';
import AppShell from '@/components/AppShell';
import { api, getUser } from '@/lib/api';
import toast from 'react-hot-toast';

export default function ProfileSettings() {
  const [form, setForm] = useState({ name: '', phone: '' });
  const [pwd, setPwd] = useState({ current: '', next: '' });

  useEffect(() => {
    const u = getUser();
    if (u) setForm({ name: u.name || '', phone: u.phone || '' });
  }, []);

  const saveProfile = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await api.put('/auth/me', form);
      toast.success('Profile updated');
    } catch (e: any) {
      toast.error(e.response?.data?.message || 'Failed');
    }
  };

  const changePwd = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await api.put('/auth/change-password', pwd);
      toast.success('Password changed');
      setPwd({ current: '', next: '' });
    } catch (e: any) {
      toast.error(e.response?.data?.message || 'Failed');
    }
  };

  return (
    <AppShell mode="user">
      <h1 className="text-2xl font-bold mb-6">Settings</h1>

      <div className="grid md:grid-cols-2 gap-6">
        <form onSubmit={saveProfile} className="card space-y-4">
          <h2 className="font-bold">Profile</h2>
          <div>
            <label className="label">Name</label>
            <input className="input" value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} />
          </div>
          <div>
            <label className="label">Phone</label>
            <input className="input" value={form.phone} onChange={(e) => setForm({ ...form, phone: e.target.value })} />
          </div>
          <button className="btn-primary">Save</button>
        </form>

        <form onSubmit={changePwd} className="card space-y-4">
          <h2 className="font-bold">Change Password</h2>
          <div>
            <label className="label">Current password</label>
            <input type="password" className="input" value={pwd.current} onChange={(e) => setPwd({ ...pwd, current: e.target.value })} />
          </div>
          <div>
            <label className="label">New password</label>
            <input type="password" className="input" value={pwd.next} onChange={(e) => setPwd({ ...pwd, next: e.target.value })} />
          </div>
          <button className="btn-primary">Update Password</button>
        </form>
      </div>
    </AppShell>
  );
}
