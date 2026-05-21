'use client';
import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';
import { clearAuth, getUser } from '@/lib/api';
import {
  LayoutDashboard, CreditCard, Receipt, Settings, LogOut, Users,
  PackageOpen, ShieldCheck, BarChart3, Sliders,
} from 'lucide-react';

type Item = { href: string; label: string; icon: any };

const userNav: Item[] = [
  { href: '/dashboard', label: 'Dashboard', icon: LayoutDashboard },
  { href: '/dashboard/plans', label: 'Plans', icon: PackageOpen },
  { href: '/dashboard/billing', label: 'Billing', icon: Receipt },
  { href: '/dashboard/settings', label: 'Settings', icon: Settings },
];

const adminNav: Item[] = [
  { href: '/admin', label: 'Overview', icon: LayoutDashboard },
  { href: '/admin/users', label: 'Users', icon: Users },
  { href: '/admin/plans', label: 'Plans', icon: PackageOpen },
  { href: '/admin/subscriptions', label: 'Subscriptions', icon: ShieldCheck },
  { href: '/admin/payments', label: 'Payments', icon: CreditCard },
  { href: '/admin/analytics', label: 'Analytics', icon: BarChart3 },
  { href: '/admin/settings', label: 'Settings', icon: Sliders },
];

export default function AppShell({ children, mode }: { children: React.ReactNode; mode: 'user' | 'admin' }) {
  const path = usePathname();
  const router = useRouter();
  const [user, setUser] = useState<any>(null);
  const nav = mode === 'admin' ? adminNav : userNav;

  useEffect(() => {
    const u = getUser();
    if (!u) {
      router.replace('/login');
      return;
    }
    if (mode === 'admin' && !['superadmin', 'admin'].includes(u.role)) {
      router.replace('/dashboard');
      return;
    }
    setUser(u);
  }, [mode, router]);

  const logout = () => {
    clearAuth();
    router.push('/login');
  };

  if (!user) {
    return (
      <div className="min-h-screen bg-fildbg flex items-center justify-center">
        <div className="flex flex-col items-center gap-3">
          <div className="w-8 h-8 border-2 border-primary border-t-transparent rounded-full animate-spin" />
          <p className="text-sm text-textgrey">Redirecting...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-fildbg flex">
      <aside className="hidden md:flex w-64 bg-white border-r border-fildbg flex-col">
        <Link href="/" className="h-16 flex items-center gap-2 px-6 border-b border-fildbg">
          <div className="w-8 h-8 rounded-lg bg-primary text-white font-bold flex items-center justify-center">M</div>
          <span className="font-bold">MeetLead {mode === 'admin' && <span className="text-red text-xs ml-1">ADMIN</span>}</span>
        </Link>
        <nav className="flex-1 p-3 space-y-1">
          {nav.map((it) => {
            const active = path === it.href || (it.href !== '/admin' && it.href !== '/dashboard' && path.startsWith(it.href));
            return (
              <Link
                key={it.href}
                href={it.href}
                className={`flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm font-medium transition ${
                  active ? 'bg-light text-primary' : 'text-textgrey hover:bg-fildbg'
                }`}
              >
                <it.icon size={18} />
                {it.label}
              </Link>
            );
          })}
        </nav>
        <div className="p-3 border-t border-fildbg">
          <div className="px-4 py-2 text-sm">
            <p className="font-medium truncate">{user.name}</p>
            <p className="text-textgrey text-xs truncate">{user.email}</p>
          </div>
          <button onClick={logout} className="flex items-center gap-3 px-4 py-2 w-full text-sm text-red hover:bg-red/5 rounded-lg">
            <LogOut size={18} /> Logout
          </button>
        </div>
      </aside>

      <div className="flex-1 flex flex-col min-w-0">
        <header className="md:hidden h-14 bg-white border-b border-fildbg px-4 flex items-center justify-between">
          <span className="font-bold">MeetLead Pro</span>
          <button onClick={logout} className="text-sm text-red"><LogOut size={18} /></button>
        </header>
        <main className="flex-1 p-4 md:p-8 overflow-x-hidden">{children}</main>
      </div>
    </div>
  );
}
