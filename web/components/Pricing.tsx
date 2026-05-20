'use client';
import { useEffect, useState } from 'react';
import { api } from '@/lib/api';
import { Check } from 'lucide-react';
import Link from 'next/link';

export default function Pricing() {
  const [plans, setPlans] = useState<any[]>([]);

  useEffect(() => {
    api.get('/plans/public').then((r) => setPlans(r.data.data)).catch(() => {});
  }, []);

  return (
    <section id="pricing" className="py-20 bg-fildbg">
      <div className="max-w-7xl mx-auto px-4 sm:px-6">
        <div className="text-center mb-12">
          <h2 className="text-3xl md:text-4xl font-bold mb-3">Simple, Affordable Pricing</h2>
          <p className="text-textgrey">Choose a plan. Cancel anytime. 7-day free trial included.</p>
        </div>

        <div className="grid md:grid-cols-3 gap-6">
          {plans.length === 0 ? (
            <div className="md:col-span-3 text-center text-textgrey py-16">Loading plans...</div>
          ) : (
            plans.map((p) => (
              <div
                key={p._id}
                className={`bg-white rounded-2xl p-8 border-2 ${
                  p.isPopular ? 'border-primary shadow-soft scale-105' : 'border-fildbg'
                } relative`}
              >
                {p.isPopular && (
                  <div className="absolute -top-3 left-1/2 -translate-x-1/2 bg-primary text-white text-xs font-bold px-3 py-1 rounded-full">
                    MOST POPULAR
                  </div>
                )}
                <h3 className="text-xl font-bold mb-1">{p.name}</h3>
                <p className="text-textgrey text-sm mb-4">{p.description}</p>
                <div className="mb-6">
                  <span className="text-4xl font-bold text-primary">₹{p.price}</span>
                  <span className="text-textgrey"> / {p.durationMonths} months</span>
                </div>
                <ul className="space-y-3 mb-6">
                  {(p.features || []).map((f: any, i: number) => (
                    <li key={i} className="flex items-start gap-2 text-sm">
                      <Check size={18} className={f.included ? 'text-primary' : 'text-textgrey/30'} />
                      <span className={f.included ? '' : 'line-through text-textgrey'}>{f.name}</span>
                    </li>
                  ))}
                </ul>
                <Link
                  href={`/checkout?plan=${p._id}`}
                  className={p.isPopular ? 'btn-primary w-full' : 'btn-outline w-full'}
                >
                  Get Started
                </Link>
              </div>
            ))
          )}
        </div>
      </div>
    </section>
  );
}
