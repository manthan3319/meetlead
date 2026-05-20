'use client';
import Link from 'next/link';
import { useEffect, useState } from 'react';
import { getUser } from '@/lib/api';
import { Menu, X } from 'lucide-react';

export default function Navbar() {
  const [open, setOpen] = useState(false);
  const [user, setUser] = useState<any>(null);

  useEffect(() => setUser(getUser()), []);

  return (
    <header className="sticky top-0 z-40 bg-white/80 backdrop-blur border-b border-fildbg">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 h-16 flex items-center justify-between">
        <Link href="/" className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-lg bg-primary flex items-center justify-center text-white font-bold">M</div>
          <span className="font-bold text-lg">MeetLead Pro</span>
        </Link>

        <nav className="hidden md:flex items-center gap-8 text-sm font-medium text-textgrey">
          <a href="#features" className="hover:text-primary">Features</a>
          <a href="#pricing" className="hover:text-primary">Pricing</a>
          <a href="#how" className="hover:text-primary">How it works</a>
          <a href="#contact" className="hover:text-primary">Contact</a>
        </nav>

        <div className="hidden md:flex items-center gap-3">
          {user ? (
            <Link
              href={user.role === 'superadmin' || user.role === 'admin' ? '/admin' : '/dashboard'}
              className="btn-primary"
            >
              Go to Dashboard
            </Link>
          ) : (
            <>
              <Link href="/login" className="btn-ghost">Login</Link>
              <Link href="/signup" className="btn-primary">Start Free Trial</Link>
            </>
          )}
        </div>

        <button className="md:hidden p-2" onClick={() => setOpen(!open)} aria-label="Menu">
          {open ? <X size={22} /> : <Menu size={22} />}
        </button>
      </div>

      {open && (
        <div className="md:hidden border-t border-fildbg bg-white">
          <div className="px-4 py-4 flex flex-col gap-3">
            <a href="#features" onClick={() => setOpen(false)}>Features</a>
            <a href="#pricing" onClick={() => setOpen(false)}>Pricing</a>
            <a href="#how" onClick={() => setOpen(false)}>How it works</a>
            <a href="#contact" onClick={() => setOpen(false)}>Contact</a>
            <div className="flex gap-2 pt-2">
              <Link href="/login" className="btn-outline flex-1">Login</Link>
              <Link href="/signup" className="btn-primary flex-1">Sign up</Link>
            </div>
          </div>
        </div>
      )}
    </header>
  );
}
