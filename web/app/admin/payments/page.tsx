'use client';
import { useEffect, useState } from 'react';
import AppShell from '@/components/AppShell';
import { api } from '@/lib/api';

export default function AdminPayments() {
  const [items, setItems] = useState<any[]>([]);
  const [filter, setFilter] = useState('');

  useEffect(() => {
    api.get('/payments/admin/all', { params: { status: filter } })
      .then((r) => setItems(r.data.data));
  }, [filter]);

  return (
    <AppShell mode="admin">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Payments</h1>
        <select className="input w-40" value={filter} onChange={(e) => setFilter(e.target.value)}>
          <option value="">All</option>
          <option value="paid">Paid</option>
          <option value="failed">Failed</option>
          <option value="created">Pending</option>
        </select>
      </div>

      <div className="card p-0 overflow-x-auto">
        <table className="w-full text-sm">
          <thead className="bg-fildbg">
            <tr className="text-left">
              <th className="px-4 py-3">Date</th>
              <th className="px-4 py-3">User</th>
              <th className="px-4 py-3">Plan</th>
              <th className="px-4 py-3">Amount</th>
              <th className="px-4 py-3">Razorpay ID</th>
              <th className="px-4 py-3">Status</th>
            </tr>
          </thead>
          <tbody>
            {items.map((p) => (
              <tr key={p._id} className="border-t border-fildbg">
                <td className="px-4 py-3 text-textgrey">{new Date(p.createdAt).toLocaleString()}</td>
                <td className="px-4 py-3">
                  <p className="font-medium">{p.userId?.name}</p>
                  <p className="text-textgrey text-xs">{p.userId?.email}</p>
                </td>
                <td className="px-4 py-3">{p.planId?.name}</td>
                <td className="px-4 py-3 font-medium">₹{p.amount}</td>
                <td className="px-4 py-3 font-mono text-xs">{p.razorpayPaymentId || '—'}</td>
                <td className="px-4 py-3">
                  <span className={`chip ${
                    p.status === 'paid' ? 'bg-light text-primary' :
                    p.status === 'failed' ? 'bg-red/10 text-red' :
                    'bg-fildbg text-textgrey'
                  }`}>{p.status}</span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </AppShell>
  );
}
