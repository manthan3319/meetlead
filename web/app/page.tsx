import Navbar from '@/components/Navbar';
import Footer from '@/components/Footer';
import Pricing from '@/components/Pricing';
import Link from 'next/link';
import {
  Calendar,
  Bell,
  Mic,
  Users,
  MessageCircle,
  TrendingUp,
  AlarmClock,
  Smartphone,
  Sparkles,
  CheckCircle2,
} from 'lucide-react';

const features = [
  { icon: Bell, title: 'Smart Reminders', desc: 'Alarm-style alerts so you never miss a meeting. 1 day, 1 hour, 15 min, and at-time alerts.' },
  { icon: Mic, title: 'Voice AI Assistant', desc: 'Just say "Hey Meet" to schedule meetings, find leads, or add notes — even offline.' },
  { icon: Users, title: 'Lead Management', desc: 'Capture, qualify, assign, and track every lead from first contact to closed deal.' },
  { icon: Calendar, title: 'Meeting Scheduler', desc: 'Online, offline, or phone meetings — with auto reminders and pre-meeting briefs.' },
  { icon: MessageCircle, title: 'WhatsApp Built-in', desc: 'One-tap WhatsApp messages with templates. No paid API needed.' },
  { icon: TrendingUp, title: 'Pipeline & Analytics', desc: 'Visual sales pipeline, conversion rates, staff performance — all in one place.' },
  { icon: AlarmClock, title: 'Follow-up Automation', desc: 'Smart suggestions for when to follow up, with ready-made message templates.' },
  { icon: Smartphone, title: 'Works Offline', desc: 'Add leads, take meeting notes, set reminders — all without internet. Auto-syncs when online.' },
];

const steps = [
  { n: 1, title: 'Sign up free', desc: 'Create your account in 30 seconds. 7-day free trial, no card needed.' },
  { n: 2, title: 'Add your team', desc: 'Invite sales staff, calling team, managers. Set roles and permissions.' },
  { n: 3, title: 'Capture leads', desc: 'Add leads from WhatsApp, calls, website, walk-ins. Assign to staff.' },
  { n: 4, title: 'Schedule & deliver', desc: 'Set meetings with smart reminders. Take notes. Follow up. Close deals.' },
];

export default function HomePage() {
  return (
    <main className="min-h-screen flex flex-col">
      <Navbar />

      <section className="relative overflow-hidden bg-gradient-to-br from-light via-white to-light">
        <div className="absolute inset-0 opacity-30 pointer-events-none">
          <div className="absolute top-20 left-10 w-72 h-72 bg-primary/20 rounded-full blur-3xl" />
          <div className="absolute bottom-10 right-10 w-96 h-96 bg-teal700/20 rounded-full blur-3xl" />
        </div>
        <div className="relative max-w-7xl mx-auto px-4 sm:px-6 py-20 md:py-28 text-center">
          <div className="inline-flex items-center gap-2 bg-white border border-primary/20 rounded-full px-4 py-1.5 text-sm font-medium text-primary mb-6 shadow-soft">
            <Sparkles size={16} />
            India's first AI-powered Meeting + Lead CRM
          </div>
          <h1 className="text-4xl md:text-6xl font-bold leading-tight mb-6 max-w-4xl mx-auto">
            Never forget a meeting. <span className="text-primary">Never lose a lead.</span>
          </h1>
          <p className="text-lg md:text-xl text-textgrey max-w-2xl mx-auto mb-8">
            One app for your meetings, leads, follow-ups, and team. Built specially for Indian agencies, freelancers, and small businesses.
          </p>
          <div className="flex flex-col sm:flex-row gap-3 justify-center">
            <Link href="/signup" className="btn-primary text-lg px-8 py-3">Start 7-Day Free Trial</Link>
            <a href="#features" className="btn-outline text-lg px-8 py-3">See Features</a>
          </div>
          <div className="mt-8 flex items-center justify-center gap-6 text-sm text-textgrey">
            <span className="flex items-center gap-1"><CheckCircle2 size={16} className="text-primary" /> No credit card</span>
            <span className="flex items-center gap-1"><CheckCircle2 size={16} className="text-primary" /> Cancel anytime</span>
            <span className="flex items-center gap-1"><CheckCircle2 size={16} className="text-primary" /> Hinglish support</span>
          </div>
        </div>
      </section>

      <section id="features" className="py-20">
        <div className="max-w-7xl mx-auto px-4 sm:px-6">
          <div className="text-center mb-12">
            <h2 className="text-3xl md:text-4xl font-bold mb-3">Everything you need to close more deals</h2>
            <p className="text-textgrey max-w-2xl mx-auto">
              Replace your scattered tools — WhatsApp + Excel + Calendar + Notes — with one focused platform.
            </p>
          </div>
          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
            {features.map((f) => (
              <div key={f.title} className="card hover:border-primary/30 hover:shadow-soft transition">
                <div className="w-12 h-12 rounded-xl bg-light flex items-center justify-center text-primary mb-4">
                  <f.icon size={22} />
                </div>
                <h3 className="font-bold mb-2">{f.title}</h3>
                <p className="text-sm text-textgrey">{f.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section id="how" className="py-20 bg-fildbg">
        <div className="max-w-7xl mx-auto px-4 sm:px-6">
          <div className="text-center mb-12">
            <h2 className="text-3xl md:text-4xl font-bold mb-3">How it works</h2>
            <p className="text-textgrey">From signup to your first closed deal — in 4 simple steps.</p>
          </div>
          <div className="grid md:grid-cols-4 gap-6">
            {steps.map((s) => (
              <div key={s.n} className="card text-center">
                <div className="w-12 h-12 rounded-full bg-primary text-white font-bold flex items-center justify-center mx-auto mb-4 text-lg">
                  {s.n}
                </div>
                <h3 className="font-bold mb-2">{s.title}</h3>
                <p className="text-sm text-textgrey">{s.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      <Pricing />

      <section id="contact" className="py-20">
        <div className="max-w-4xl mx-auto px-4 sm:px-6">
          <div className="bg-primary rounded-3xl p-10 md:p-16 text-white text-center relative overflow-hidden">
            <div className="absolute top-0 right-0 w-64 h-64 bg-teal700/30 rounded-full blur-3xl" />
            <div className="relative">
              <h2 className="text-3xl md:text-4xl font-bold mb-4">Ready to stop missing meetings?</h2>
              <p className="text-white/90 mb-8 max-w-2xl mx-auto">
                Join hundreds of agencies and freelancers managing their entire client lifecycle on MeetLead Pro.
              </p>
              <Link href="/signup" className="inline-block bg-white text-primary font-bold px-8 py-3 rounded-lg hover:bg-light transition">
                Start Free Trial →
              </Link>
            </div>
          </div>
        </div>
      </section>

      <Footer />
    </main>
  );
}
