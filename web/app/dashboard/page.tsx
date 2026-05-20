'use client';
import { useEffect, useState } from 'react';
import AppShell from '@/components/AppShell';
import { api } from '@/lib/api';
import { Clock, CheckCircle, AlertCircle, Smartphone } from 'lucide-react';
import Link from 'next/link';

export default function UserDashboard() {
  const [sub, setSub] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.get('/subscriptions/current')
      .then((r) => setSub(r.data.data))
      .finally(() => setLoading(false));
  }, []);

  const daysLeft = sub?.endDate
    ? Math.max(0, Math.ceil((new Date(sub.endDate).getTime() - Date.now()) / (1000 * 60 * 60 * 24)))
    : 0;

  return (
    <AppShell mode="user">
      <h1 className="text-2xl font-bold mb-2">Welcome back!</h1>
      <p className="text-textgrey mb-6">Here's your subscription overview.</p>

      {loading ? (
        <div className="text-textgrey">Loading...</div>
      ) : sub ? (
        <div className="grid md:grid-cols-3 gap-4 mb-8">
          <div className="card">
            <div className="flex items-center gap-3 mb-2">
              <div className="w-10 h-10 rounded-lg bg-light text-primary flex items-center justify-center">
                <CheckCircle size={20} />
              </div>
              <div>
                <p className="text-sm text-textgrey">Current Plan</p>
                <p className="font-bold">{sub.planId?.name}</p>
              </div>
            </div>
            <span className={`chip ${sub.status === 'trial' ? 'bg-light text-primary' : 'bg-primary/10 text-primary'}`}>
              {sub.status?.toUpperCase()}
            </span>
          </div>
          <div className="card">
            <div className="flex items-center gap-3 mb-2">
              <div className="w-10 h-10 rounded-lg bg-light text-primary flex items-center justify-center">
                <Clock size={20} />
              </div>
              <div>
                <p className="text-sm text-textgrey">Days Remaining</p>
                <p className="font-bold text-2xl">{daysLeft}</p>
              </div>
            </div>
            <p className="text-xs text-textgrey">
              Expires on {sub.endDate ? new Date(sub.endDate).toLocaleDateString() : '—'}
            </p>
          </div>
          <div className="card">
            <div className="flex items-center gap-3 mb-2">
              <div className="w-10 h-10 rounded-lg bg-light text-primary flex items-center justify-center">
                <Smartphone size={20} />
              </div>
              <div>
                <p className="text-sm text-textgrey">Mobile App</p>
                <p className="font-bold">Use Now</p>
              </div>
            </div>
            <p className="text-xs text-textgrey">Login with same credentials in the Flutter app.</p>
          </div>
        </div>
      ) : (
        <div className="card border-red/30 bg-red/5 mb-8">
          <div className="flex items-center gap-3">
            <AlertCircle className="text-red" />
            <div>
              <p className="font-bold text-red">No active subscription</p>
              <p className="text-sm text-textgrey">Pick a plan below to start using MeetLead Pro.</p>
            </div>
          </div>
        </div>
      )}

      <div className="card">
        <h2 className="text-lg font-bold mb-2">Upgrade or Renew</h2>
        <p className="text-textgrey mb-4">Choose from our plans to keep accessing the app without interruption.</p>
        <Link href="/dashboard/plans" className="btn-primary">View Plans</Link>
      </div>
    </AppShell>
  );
}
