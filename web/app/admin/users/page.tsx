'use client';
import { useEffect, useState } from 'react';
import AppShell from '@/components/AppShell';
import { api } from '@/lib/api';
import toast from 'react-hot-toast';
import { Search } from 'lucide-react';

export default function AdminUsers() {
  const [items, setItems] = useState<any[]>([]);
  const [q, setQ] = useState('');
  const [loading, setLoading] = useState(true);

  const load = (search = '') => {
    setLoading(true);
    api.get('/admin/users', { params: { q: search } })
      .then((r) => setItems(r.data.data))
      .finally(() => setLoading(false));
  };

  useEffect(() => { load(); }, []);

  const toggle = async (id: string) => {
    try {
      await api.patch(`/admin/users/${id}/toggle`);
      toast.success('Updated');
      load(q);
    } catch (e: any) {
      toast.error(e.response?.data?.message || 'Failed');
    }
  };

  const changeRole = async (id: string, role: string) => {
    try {
      await api.patch(`/admin/users/${id}/role`, { role });
      toast.success('Role updated');
      load(q);
    } catch (e: any) {
      toast.error('Failed');
    }
  };

  return (
    <AppShell mode="admin">
      <div className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-bold">Users</h1>
        <div className="relative">
          <Search className="absolute left-3 top-2.5 text-textgrey" size={18} />
          <input
            className="input pl-10 w-64"
            placeholder="Search by name or email"
            value={q}
            onChange={(e) => setQ(e.target.value)}
            onKeyDown={(e) => e.key === 'Enter' && load(q)}
          />
        </div>
      </div>

      <div className="card p-0 overflow-x-auto">
        <table className="w-full text-sm">
          <thead className="bg-fildbg">
            <tr className="text-left">
              <th className="px-4 py-3">Name</th>
              <th className="px-4 py-3">Email</th>
              <th className="px-4 py-3">Org</th>
              <th className="px-4 py-3">Role</th>
              <th className="px-4 py-3">Joined</th>
              <th className="px-4 py-3">Status</th>
              <th className="px-4 py-3">Action</th>
            </tr>
          </thead>
          <tbody>
            {loading && <tr><td colSpan={7} className="p-8 text-center text-textgrey">Loading...</td></tr>}
            {!loading && items.length === 0 && (
              <tr><td colSpan={7} className="p-8 text-center text-textgrey">No users</td></tr>
            )}
            {items.map((u) => (
              <tr key={u._id} className="border-t border-fildbg">
                <td className="px-4 py-3 font-medium">{u.name}</td>
                <td className="px-4 py-3 text-textgrey">{u.email}</td>
                <td className="px-4 py-3 text-textgrey">{u.organizationId?.name || '—'}</td>
                <td className="px-4 py-3">
                  <select
                    value={u.role}
                    onChange={(e) => changeRole(u._id, e.target.value)}
                    className="bg-fildbg border-0 rounded px-2 py-1 text-xs"
                  >
                    {['owner', 'manager', 'sales', 'calling', 'support', 'admin', 'superadmin'].map((r) => (
                      <option key={r} value={r}>{r}</option>
                    ))}
                  </select>
                </td>
                <td className="px-4 py-3 text-textgrey">{new Date(u.createdAt).toLocaleDateString()}</td>
                <td className="px-4 py-3">
                  <span className={`chip ${u.isActive ? 'bg-light text-primary' : 'bg-red/10 text-red'}`}>
                    {u.isActive ? 'Active' : 'Disabled'}
                  </span>
                </td>
                <td className="px-4 py-3">
                  <button onClick={() => toggle(u._id)} className="text-xs text-primary hover:underline">
                    {u.isActive ? 'Disable' : 'Enable'}
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </AppShell>
  );
}
