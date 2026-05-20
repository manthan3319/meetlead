'use client';
import { useEffect, useState } from 'react';
import AppShell from '@/components/AppShell';
import { api } from '@/lib/api';

export default function AdminSubscriptions() {
  const [items, setItems] = useState<any[]>([]);
  const [filter, setFilter] = useState('');

  const load = () => {
    api.get('/subscriptions/admin/all', { params: { status: filter } })
      .then((r) => setItems(r.data.data));
  };

  useEffect(() => { load(); }, [filter]);

  return (
    <AppShell mode="admin">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Subscriptions</h1>
        <select className="input w-40" value={filter} onChange={(e) => setFilter(e.target.value)}>
          <option value="">All</option>
          <option value="active">Active</option>
          <option value="trial">Trial</option>
          <option value="expired">Expired</option>
          <option value="cancelled">Cancelled</option>
        </select>
      </div>

      <div className="card p-0 overflow-x-auto">
        <table className="w-full text-sm">
          <thead className="bg-fildbg">
            <tr className="text-left">
              <th className="px-4 py-3">User</th>
              <th className="px-4 py-3">Plan</th>
              <th className="px-4 py-3">Start</th>
              <th className="px-4 py-3">End</th>
              <th className="px-4 py-3">Amount</th>
              <th className="px-4 py-3">Status</th>
            </tr>
          </thead>
          <tbody>
            {items.map((s) => (
              <tr key={s._id} className="border-t border-fildbg">
                <td className="px-4 py-3">
                  <p className="font-medium">{s.userId?.name}</p>
                  <p className="text-textgrey text-xs">{s.userId?.email}</p>
                </td>
                <td className="px-4 py-3">{s.planId?.name}</td>
                <td className="px-4 py-3 text-textgrey">{s.startDate ? new Date(s.startDate).toLocaleDateString() : '—'}</td>
                <td className="px-4 py-3 text-textgrey">{s.endDate ? new Date(s.endDate).toLocaleDateString() : '—'}</td>
                <td className="px-4 py-3 font-medium">₹{s.amountPaid || 0}</td>
                <td className="px-4 py-3">
                  <span className={`chip ${
                    s.status === 'active' ? 'bg-light text-primary' :
                    s.status === 'trial' ? 'bg-light text-primary' :
                    s.status === 'expired' ? 'bg-red/10 text-red' :
                    'bg-fildbg text-textgrey'
                  }`}>{s.status}</span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </AppShell>
  );
}
