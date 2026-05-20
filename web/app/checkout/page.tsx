'use client';
import { Suspense, useEffect, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import toast from 'react-hot-toast';
import { api, getUser } from '@/lib/api';
import { ShieldCheck } from 'lucide-react';

declare global {
  interface Window { Razorpay: any }
}

function loadRazorpayScript() {
  return new Promise<boolean>((resolve) => {
    if (typeof window === 'undefined') return resolve(false);
    if (window.Razorpay) return resolve(true);
    const s = document.createElement('script');
    s.src = 'https://checkout.razorpay.com/v1/checkout.js';
    s.onload = () => resolve(true);
    s.onerror = () => resolve(false);
    document.body.appendChild(s);
  });
}

function CheckoutInner() {
  const search = useSearchParams();
  const router = useRouter();
  const planId = search.get('plan');
  const [plan, setPlan] = useState<any>(null);
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    if (!getUser()) {
      router.replace(`/login?redirect=/checkout?plan=${planId}`);
      return;
    }
    if (planId) api.get(`/plans/${planId}`).then((r) => setPlan(r.data.data));
  }, [planId, router]);

  const pay = async () => {
    if (!plan) return;
    setBusy(true);
    try {
      const ok = await loadRazorpayScript();
      if (!ok) throw new Error('Razorpay SDK failed to load');

      const { data } = await api.post('/payments/order', { planId: plan._id });
      if (!data.keyId) {
        toast.error('Payment gateway not configured. Contact admin.');
        return;
      }

      const rzp = new window.Razorpay({
        key: data.keyId,
        amount: data.order.amount,
        currency: data.order.currency,
        name: 'MeetLead Pro',
        description: plan.name,
        order_id: data.order.id,
        prefill: { name: getUser()?.name, email: getUser()?.email },
        theme: { color: '#008088' },
        handler: async (resp: any) => {
          try {
            await api.post('/payments/verify', resp);
            toast.success('Payment successful! Subscription activated.');
            router.push('/dashboard');
          } catch (e: any) {
            toast.error(e.response?.data?.message || 'Verification failed');
          }
        },
        modal: { ondismiss: () => setBusy(false) },
      });
      rzp.open();
    } catch (e: any) {
      toast.error(e.message || 'Could not start payment');
      setBusy(false);
    }
  };

  if (!plan) {
    return <div className="min-h-screen flex items-center justify-center bg-fildbg">Loading...</div>;
  }

  return (
    <main className="min-h-screen bg-fildbg p-4 md:p-10">
      <div className="max-w-3xl mx-auto card">
        <h1 className="text-2xl font-bold mb-1">Checkout</h1>
        <p className="text-textgrey mb-6">Review your order and pay securely.</p>

        <div className="border border-fildbg rounded-xl p-5 mb-6 bg-fildbg/40">
          <div className="flex justify-between items-start mb-3">
            <div>
              <p className="text-sm text-textgrey">Plan</p>
              <p className="font-bold text-lg">{plan.name}</p>
              <p className="text-sm text-textgrey">{plan.description}</p>
            </div>
            <div className="text-right">
              <p className="text-sm text-textgrey">Duration</p>
              <p className="font-bold">{plan.durationMonths} months</p>
            </div>
          </div>
          <div className="border-t border-fildbg pt-3 flex justify-between items-center">
            <span className="font-medium">Total</span>
            <span className="text-2xl font-bold text-primary">₹{plan.price}</span>
          </div>
        </div>

        <button onClick={pay} disabled={busy} className="btn-primary w-full text-lg py-3">
          {busy ? 'Processing...' : `Pay ₹${plan.price} with Razorpay`}
        </button>

        <p className="flex items-center justify-center gap-2 mt-4 text-sm text-textgrey">
          <ShieldCheck size={16} /> Secured by Razorpay. 256-bit SSL.
        </p>
      </div>
    </main>
  );
}

export default function CheckoutPage() {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <CheckoutInner />
    </Suspense>
  );
}
