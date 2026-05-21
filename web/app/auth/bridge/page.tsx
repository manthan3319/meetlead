'use client';
import { Suspense, useEffect, useRef, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import axios from 'axios';
import toast from 'react-hot-toast';
import { setAuth } from '@/lib/api';

function BridgeInner() {
  const router = useRouter();
  const params = useSearchParams();
  const ran = useRef(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (ran.current) return;
    ran.current = true;

    const token = params.get('token');
    const next = params.get('next') || '/dashboard/plans';

    if (!token) {
      setError('Missing token. Please sign in.');
      setTimeout(() => router.replace('/login'), 1500);
      return;
    }

    const apiHost = typeof window !== 'undefined' ? window.location.hostname : 'localhost';
    const baseURL =
      process.env.NEXT_PUBLIC_API_URL || `http://${apiHost}:5000/api`;
    axios
      .get(`${baseURL}/auth/me`, {
        headers: { Authorization: `Bearer ${token}` },
        timeout: 15000,
      })
      .then((r) => {
        const user = r.data?.user;
        if (!user) throw new Error('Invalid response');
        setAuth(token, user);
        toast.success(`Welcome, ${user.name || 'back'}!`);
        router.replace(next);
      })
      .catch((e) => {
        const msg = e?.response?.data?.message || 'Session expired. Please sign in again.';
        setError(msg);
        setTimeout(() => router.replace('/login'), 1800);
      });
  }, [params, router]);

  return (
    <main className="min-h-screen flex items-center justify-center bg-fildbg p-4">
      <div className="flex flex-col items-center gap-4">
        {error ? (
          <>
            <div className="w-12 h-12 rounded-full bg-red/10 text-red flex items-center justify-center text-2xl">!</div>
            <p className="text-red font-medium">{error}</p>
            <p className="text-sm text-textgrey">Redirecting to login...</p>
          </>
        ) : (
          <>
            <div className="w-10 h-10 border-2 border-primary border-t-transparent rounded-full animate-spin" />
            <p className="text-sm text-textgrey">Signing you in...</p>
          </>
        )}
      </div>
    </main>
  );
}

export default function AuthBridgePage() {
  return (
    <Suspense
      fallback={
        <main className="min-h-screen flex items-center justify-center bg-fildbg">
          <div className="w-10 h-10 border-2 border-primary border-t-transparent rounded-full animate-spin" />
        </main>
      }
    >
      <BridgeInner />
    </Suspense>
  );
}
