'use client';
import { useEffect, useState } from 'react';
import AppShell from '@/components/AppShell';
import { api } from '@/lib/api';
import toast from 'react-hot-toast';
import { KeyRound, Globe, Save } from 'lucide-react';

type Setting = { _id?: string; key: string; value: any; group?: string; description?: string; isPublic?: boolean; hasValue?: boolean };

const KNOWN_SETTINGS = [
  { key: 'site_name', label: 'Site Name', group: 'general', isPublic: true },
  { key: 'site_tagline', label: 'Tagline', group: 'general', isPublic: true },
  { key: 'support_email', label: 'Support Email', group: 'general', isPublic: true },
  { key: 'support_phone', label: 'Support Phone', group: 'general', isPublic: true },
  { key: 'currency', label: 'Currency', group: 'payment', isPublic: true },
  { key: 'razorpay_key_id', label: 'Razorpay Key ID', group: 'payment', isPublic: false },
  { key: 'razorpay_key_secret', label: 'Razorpay Key Secret', group: 'payment', isPublic: false, secret: true },
];

export default function AdminSettings() {
  const [data, setData] = useState<Record<string, any>>({});
  const [meta, setMeta] = useState<Record<string, Setting>>({});
  const [saving, setSaving] = useState(false);

  const load = async () => {
    const r = await api.get('/settings');
    const map: Record<string, any> = {};
    const m: Record<string, Setting> = {};
    r.data.data.forEach((s: Setting) => {
      map[s.key] = s.value;
      m[s.key] = s;
    });
    setData(map);
    setMeta(m);
  };

  useEffect(() => { load(); }, []);

  const save = async (group?: string) => {
    setSaving(true);
    try {
      const settings = KNOWN_SETTINGS
        .filter((k) => !group || k.group === group)
        .map((k) => {
          let value = data[k.key];
          if (meta[k.key]?.hasValue && typeof value === 'string' && value.startsWith('••••••')) {
            return null;
          }
          return { key: k.key, value, group: k.group, isPublic: k.isPublic };
        })
        .filter(Boolean);
      await api.post('/settings/bulk', { settings });
      toast.success('Settings saved');
      load();
    } catch (e: any) {
      toast.error(e.response?.data?.message || 'Failed');
    } finally {
      setSaving(false);
    }
  };

  const generalKeys = KNOWN_SETTINGS.filter((k) => k.group === 'general');
  const paymentKeys = KNOWN_SETTINGS.filter((k) => k.group === 'payment');

  return (
    <AppShell mode="admin">
      <h1 className="text-2xl font-bold mb-6">Settings</h1>

      <div className="card mb-6">
        <div className="flex items-center gap-2 mb-4">
          <Globe className="text-primary" />
          <h2 className="font-bold">General</h2>
        </div>
        <div className="grid md:grid-cols-2 gap-4">
          {generalKeys.map((k) => (
            <div key={k.key}>
              <label className="label">{k.label}</label>
              <input
                className="input"
                value={data[k.key] || ''}
                onChange={(e) => setData({ ...data, [k.key]: e.target.value })}
              />
            </div>
          ))}
        </div>
        <button onClick={() => save('general')} disabled={saving} className="btn-primary mt-5">
          <Save size={16} /> Save General
        </button>
      </div>

      <div className="card">
        <div className="flex items-center gap-2 mb-2">
          <KeyRound className="text-primary" />
          <h2 className="font-bold">Razorpay Payment Gateway</h2>
        </div>
        <p className="text-textgrey text-sm mb-4">
          Add your Razorpay keys here. Users will use these when paying for plans.
          Get keys from{' '}
          <a href="https://dashboard.razorpay.com/app/keys" target="_blank" className="text-primary underline" rel="noreferrer">
            Razorpay Dashboard
          </a>.
        </p>
        <div className="space-y-4">
          {paymentKeys.map((k) => (
            <div key={k.key}>
              <label className="label">{k.label}</label>
              <input
                className="input font-mono"
                value={data[k.key] || ''}
                placeholder={k.key === 'razorpay_key_id' ? 'rzp_test_xxxxxxxxxx' : 'Secret key'}
                onChange={(e) => setData({ ...data, [k.key]: e.target.value })}
                type={k.secret ? 'password' : 'text'}
              />
              {meta[k.key]?.hasValue && (
                <p className="text-xs text-textgrey mt-1">Currently set. Leave masked to keep unchanged.</p>
              )}
            </div>
          ))}
        </div>
        <button onClick={() => save('payment')} disabled={saving} className="btn-primary mt-5">
          <Save size={16} /> Save Razorpay Keys
        </button>
      </div>
    </AppShell>
  );
}
