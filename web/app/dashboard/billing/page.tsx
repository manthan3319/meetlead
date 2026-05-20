'use client';
import { useEffect, useState } from 'react';
import AppShell from '@/components/AppShell';
import { api } from '@/lib/api';

export default function BillingPage() {
  const [items, setItems] = useState<any[]>([]);

  useEffect(() => {
    api.get('/payments/history').then((r) => setItems(r.data.data));
  }, []);

  return (
    <AppShell mode="user">
      <h1 className="text-2xl font-bold mb-2">Billing History</h1>
      <p className="text-textgrey mb-6">Your past payments and invoices.</p>

      <div className="card overflow-x-auto p-0">
        <table className="w-full text-sm">
          <thead className="bg-fildbg">
            <tr className="text-left">
              <th className="px-4 py-3">Date</th>
              <th className="px-4 py-3">Plan</th>
              <th className="px-4 py-3">Amount</th>
              <th className="px-4 py-3">Status</th>
              <th className="px-4 py-3">Payment ID</th>
            </tr>
          </thead>
          <tbody>
            {items.length === 0 && (
              <tr><td colSpan={5} className="px-4 py-8 text-center text-textgrey">No payments yet.</td></tr>
            )}
            {items.map((p) => (
              <tr key={p._id} className="border-t border-fildbg">
                <td className="px-4 py-3">{new Date(p.createdAt).toLocaleDateString()}</td>
                <td className="px-4 py-3">{p.planId?.name || '—'}</td>
                <td className="px-4 py-3 font-medium">₹{p.amount}</td>
                <td className="px-4 py-3">
                  <span className={`chip ${
                    p.status === 'paid' ? 'bg-light text-primary' :
                    p.status === 'failed' ? 'bg-red/10 text-red' :
                    'bg-fildbg text-textgrey'
                  }`}>{p.status}</span>
                </td>
                <td className="px-4 py-3 font-mono text-xs">{p.razorpayPaymentId || '—'}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </AppShell>
  );
}
