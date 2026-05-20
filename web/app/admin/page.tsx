'use client';
import { useEffect, useState } from 'react';
import AppShell from '@/components/AppShell';
import { api } from '@/lib/api';
import { Users, Building2, ShieldCheck, IndianRupee, Target, Calendar } from 'lucide-react';
import { BarChart, Bar, XAxis, YAxis, ResponsiveContainer, Tooltip, CartesianGrid } from 'recharts';

const monthLabel = (y: number, m: number) =>
  new Date(y, m - 1, 1).toLocaleString('en', { month: 'short', year: '2-digit' });

export default function AdminHome() {
  const [stats, setStats] = useState<any>(null);
  const [chart, setChart] = useState<any[]>([]);

  useEffect(() => {
    api.get('/admin/stats').then((r) => setStats(r.data.data));
    api.get('/admin/revenue-chart').then((r) => {
      const data = r.data.data.map((x: any) => ({ label: monthLabel(x._id.y, x._id.m), total: x.total }));
      setChart(data);
    });
  }, []);

  const cards = stats ? [
    { label: 'Total Users', value: stats.users, icon: Users },
    { label: 'Organizations', value: stats.organizations, icon: Building2 },
    { label: 'Active Subs', value: stats.activeSubscriptions, icon: ShieldCheck },
    { label: 'Revenue', value: `₹${stats.revenue.toLocaleString('en-IN')}`, icon: IndianRupee },
    { label: 'Leads', value: stats.leads, icon: Target },
    { label: 'Meetings', value: stats.meetings, icon: Calendar },
  ] : [];

  return (
    <AppShell mode="admin">
      <h1 className="text-2xl font-bold mb-6">Admin Overview</h1>

      <div className="grid grid-cols-2 md:grid-cols-3 gap-4 mb-8">
        {cards.map((c) => (
          <div key={c.label} className="card">
            <div className="flex items-center justify-between mb-2">
              <p className="text-sm text-textgrey">{c.label}</p>
              <div className="w-9 h-9 rounded-lg bg-light text-primary flex items-center justify-center">
                <c.icon size={18} />
              </div>
            </div>
            <p className="text-2xl font-bold">{c.value}</p>
          </div>
        ))}
      </div>

      <div className="card">
        <h2 className="font-bold mb-4">Revenue Trend</h2>
        <div className="h-72">
          {chart.length === 0 ? (
            <p className="text-textgrey text-center py-20">No revenue data yet.</p>
          ) : (
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={chart}>
                <CartesianGrid strokeDasharray="3 3" stroke="#f5f8fa" />
                <XAxis dataKey="label" stroke="#6b7280" fontSize={12} />
                <YAxis stroke="#6b7280" fontSize={12} />
                <Tooltip />
                <Bar dataKey="total" fill="#008088" radius={[6, 6, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          )}
        </div>
      </div>
    </AppShell>
  );
}
