'use client';
import { useEffect, useState } from 'react';
import AppShell from '@/components/AppShell';
import { api } from '@/lib/api';
import { Check } from 'lucide-react';
import { useRouter } from 'next/navigation';

export default function PlansPage() {
  const router = useRouter();
  const [plans, setPlans] = useState<any[]>([]);

  useEffect(() => {
    api.get('/plans/public').then((r) => setPlans(r.data.data));
  }, []);

  return (
    <AppShell mode="user">
      <h1 className="text-2xl font-bold mb-2">Choose Your Plan</h1>
      <p className="text-textgrey mb-6">Pick a plan and pay securely via Razorpay.</p>

      <div className="grid md:grid-cols-3 gap-6">
        {plans.map((p) => (
          <div
            key={p._id}
            className={`bg-white rounded-2xl p-6 border-2 ${
              p.isPopular ? 'border-primary shadow-soft' : 'border-fildbg'
            }`}
          >
            {p.isPopular && (
              <span className="chip bg-primary text-white mb-3">MOST POPULAR</span>
            )}
            <h3 className="text-xl font-bold">{p.name}</h3>
            <p className="text-textgrey text-sm mb-4">{p.description}</p>
            <p className="mb-5">
              <span className="text-3xl font-bold text-primary">₹{p.price}</span>
              <span className="text-textgrey"> / {p.durationMonths}mo</span>
            </p>
            <ul className="space-y-2 mb-6">
              {(p.features || []).map((f: any, i: number) => (
                <li key={i} className="flex gap-2 text-sm">
                  <Check size={16} className={f.included ? 'text-primary' : 'text-textgrey/30'} />
                  <span className={f.included ? '' : 'line-through text-textgrey'}>{f.name}</span>
                </li>
              ))}
            </ul>
            <button
              onClick={() => router.push(`/checkout?plan=${p._id}`)}
              className={p.isPopular ? 'btn-primary w-full' : 'btn-outline w-full'}
            >
              Buy Now
            </button>
          </div>
        ))}
      </div>
    </AppShell>
  );
}
