'use client';
import { useEffect, useState } from 'react';
import AppShell from '@/components/AppShell';
import { api } from '@/lib/api';
import toast from 'react-hot-toast';
import { Plus, Trash2, Edit, X } from 'lucide-react';

type Plan = {
  _id?: string;
  name: string;
  slug: string;
  description: string;
  durationMonths: number;
  price: number;
  maxUsers: number;
  maxLeads: number;
  isPopular: boolean;
  isActive: boolean;
  sortOrder: number;
  features: { name: string; included: boolean }[];
};

const emptyPlan: Plan = {
  name: '', slug: '', description: '', durationMonths: 3, price: 0, maxUsers: 1, maxLeads: 500,
  isPopular: false, isActive: true, sortOrder: 0, features: [{ name: '', included: true }],
};

export default function AdminPlans() {
  const [items, setItems] = useState<any[]>([]);
  const [editing, setEditing] = useState<Plan | null>(null);

  const load = () => api.get('/plans').then((r) => setItems(r.data.data));
  useEffect(() => { load(); }, []);

  const save = async () => {
    if (!editing) return;
    try {
      if (editing._id) await api.put(`/plans/${editing._id}`, editing);
      else await api.post('/plans', editing);
      toast.success('Plan saved');
      setEditing(null);
      load();
    } catch (e: any) {
      toast.error(e.response?.data?.message || 'Failed');
    }
  };

  const remove = async (id: string) => {
    if (!confirm('Disable this plan?')) return;
    await api.delete(`/plans/${id}`);
    toast.success('Plan disabled');
    load();
  };

  return (
    <AppShell mode="admin">
      <div className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-bold">Plans / Packages</h1>
        <button onClick={() => setEditing({ ...emptyPlan })} className="btn-primary">
          <Plus size={18} /> New Plan
        </button>
      </div>

      <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
        {items.map((p) => (
          <div key={p._id} className="card">
            <div className="flex justify-between mb-2">
              <h3 className="font-bold">{p.name}</h3>
              <div className="flex gap-1">
                <button onClick={() => setEditing(p)} className="p-1.5 hover:bg-fildbg rounded"><Edit size={16} /></button>
                <button onClick={() => remove(p._id)} className="p-1.5 hover:bg-red/10 text-red rounded"><Trash2 size={16} /></button>
              </div>
            </div>
            <p className="text-textgrey text-sm mb-3">{p.description}</p>
            <p className="text-xl font-bold text-primary mb-1">₹{p.price}</p>
            <p className="text-xs text-textgrey">{p.durationMonths} months • {p.maxUsers} users • {p.maxLeads} leads</p>
            <div className="flex gap-2 mt-3">
              {p.isPopular && <span className="chip bg-primary/10 text-primary">Popular</span>}
              <span className={`chip ${p.isActive ? 'bg-light text-primary' : 'bg-red/10 text-red'}`}>
                {p.isActive ? 'Active' : 'Inactive'}
              </span>
            </div>
          </div>
        ))}
      </div>

      {editing && (
        <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
            <div className="sticky top-0 bg-white border-b border-fildbg px-6 py-4 flex justify-between">
              <h2 className="font-bold text-lg">{editing._id ? 'Edit Plan' : 'New Plan'}</h2>
              <button onClick={() => setEditing(null)}><X /></button>
            </div>
            <div className="p-6 space-y-4">
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="label">Name</label>
                  <input className="input" value={editing.name} onChange={(e) => setEditing({ ...editing, name: e.target.value })} />
                </div>
                <div>
                  <label className="label">Slug (unique)</label>
                  <input className="input" value={editing.slug} onChange={(e) => setEditing({ ...editing, slug: e.target.value })} />
                </div>
              </div>
              <div>
                <label className="label">Description</label>
                <input className="input" value={editing.description} onChange={(e) => setEditing({ ...editing, description: e.target.value })} />
              </div>
              <div className="grid grid-cols-3 gap-3">
                <div>
                  <label className="label">Price (₹)</label>
                  <input type="number" className="input" value={editing.price} onChange={(e) => setEditing({ ...editing, price: +e.target.value })} />
                </div>
                <div>
                  <label className="label">Duration (months)</label>
                  <input type="number" className="input" value={editing.durationMonths} onChange={(e) => setEditing({ ...editing, durationMonths: +e.target.value })} />
                </div>
                <div>
                  <label className="label">Sort Order</label>
                  <input type="number" className="input" value={editing.sortOrder} onChange={(e) => setEditing({ ...editing, sortOrder: +e.target.value })} />
                </div>
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="label">Max Users</label>
                  <input type="number" className="input" value={editing.maxUsers} onChange={(e) => setEditing({ ...editing, maxUsers: +e.target.value })} />
                </div>
                <div>
                  <label className="label">Max Leads</label>
                  <input type="number" className="input" value={editing.maxLeads} onChange={(e) => setEditing({ ...editing, maxLeads: +e.target.value })} />
                </div>
              </div>

              <div>
                <label className="label">Features</label>
                {editing.features.map((f, i) => (
                  <div key={i} className="flex gap-2 mb-2">
                    <input className="input flex-1" placeholder="Feature name" value={f.name}
                      onChange={(e) => {
                        const features = [...editing.features];
                        features[i].name = e.target.value;
                        setEditing({ ...editing, features });
                      }} />
                    <label className="flex items-center gap-1 px-3 bg-fildbg rounded-lg">
                      <input type="checkbox" checked={f.included}
                        onChange={(e) => {
                          const features = [...editing.features];
                          features[i].included = e.target.checked;
                          setEditing({ ...editing, features });
                        }} />
                      <span className="text-xs">Included</span>
                    </label>
                    <button
                      type="button"
                      onClick={() => setEditing({ ...editing, features: editing.features.filter((_, x) => x !== i) })}
                      className="p-2 text-red hover:bg-red/10 rounded"
                    >
                      <X size={16} />
                    </button>
                  </div>
                ))}
                <button
                  type="button"
                  onClick={() => setEditing({ ...editing, features: [...editing.features, { name: '', included: true }] })}
                  className="text-sm text-primary"
                >
                  + Add Feature
                </button>
              </div>

              <div className="flex gap-4">
                <label className="flex items-center gap-2">
                  <input type="checkbox" checked={editing.isPopular} onChange={(e) => setEditing({ ...editing, isPopular: e.target.checked })} />
                  Mark as Popular
                </label>
                <label className="flex items-center gap-2">
                  <input type="checkbox" checked={editing.isActive} onChange={(e) => setEditing({ ...editing, isActive: e.target.checked })} />
                  Active
                </label>
              </div>
            </div>
            <div className="sticky bottom-0 bg-white border-t border-fildbg px-6 py-4 flex justify-end gap-2">
              <button onClick={() => setEditing(null)} className="btn-ghost">Cancel</button>
              <button onClick={save} className="btn-primary">Save Plan</button>
            </div>
          </div>
        </div>
      )}
    </AppShell>
  );
}
