'use client';
import { useEffect, useState } from 'react';
import AppShell from '@/components/AppShell';
import { api } from '@/lib/api';
import { LineChart, Line, XAxis, YAxis, ResponsiveContainer, Tooltip, CartesianGrid } from 'recharts';

const monthLabel = (y: number, m: number) =>
  new Date(y, m - 1, 1).toLocaleString('en', { month: 'short', year: '2-digit' });

export default function AdminAnalytics() {
  const [chart, setChart] = useState<any[]>([]);

  useEffect(() => {
    api.get('/admin/revenue-chart').then((r) => {
      const data = r.data.data.map((x: any) => ({
        label: monthLabel(x._id.y, x._id.m),
        revenue: x.total,
        count: x.count,
      }));
      setChart(data);
    });
  }, []);

  return (
    <AppShell mode="admin">
      <h1 className="text-2xl font-bold mb-6">Analytics</h1>

      <div className="card mb-6">
        <h2 className="font-bold mb-4">Revenue (last 12 months)</h2>
        <div className="h-80">
          {chart.length === 0 ? (
            <p className="text-textgrey text-center py-20">No data yet.</p>
          ) : (
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={chart}>
                <CartesianGrid strokeDasharray="3 3" stroke="#f5f8fa" />
                <XAxis dataKey="label" stroke="#6b7280" fontSize={12} />
                <YAxis stroke="#6b7280" fontSize={12} />
                <Tooltip />
                <Line type="monotone" dataKey="revenue" stroke="#008088" strokeWidth={3} dot={{ fill: '#008088' }} />
              </LineChart>
            </ResponsiveContainer>
          )}
        </div>
      </div>
    </AppShell>
  );
}
