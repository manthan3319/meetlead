import Link from 'next/link';

export default function Footer() {
  return (
    <footer className="bg-dark text-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 py-12 grid grid-cols-2 md:grid-cols-4 gap-8">
        <div className="col-span-2">
          <div className="flex items-center gap-2 mb-3">
            <div className="w-8 h-8 rounded-lg bg-primary flex items-center justify-center font-bold">M</div>
            <span className="font-bold">MeetLead Pro</span>
          </div>
          <p className="text-white/70 text-sm max-w-md">
            Never forget a meeting. Never lose a lead. The smart CRM built for Indian agencies, freelancers, and small businesses.
          </p>
        </div>
        <div>
          <h4 className="font-semibold mb-3">Product</h4>
          <ul className="space-y-2 text-sm text-white/70">
            <li><a href="#features" className="hover:text-white">Features</a></li>
            <li><a href="#pricing" className="hover:text-white">Pricing</a></li>
            <li><Link href="/signup" className="hover:text-white">Free Trial</Link></li>
          </ul>
        </div>
        <div>
          <h4 className="font-semibold mb-3">Company</h4>
          <ul className="space-y-2 text-sm text-white/70">
            <li><a href="#contact" className="hover:text-white">Contact</a></li>
            <li><a href="#" className="hover:text-white">Privacy</a></li>
            <li><a href="#" className="hover:text-white">Terms</a></li>
          </ul>
        </div>
      </div>
      <div className="border-t border-white/10">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 py-4 text-sm text-white/60 flex justify-between">
          <span>© {new Date().getFullYear()} MeetLead Pro. All rights reserved.</span>
          <span>Made for India 🇮🇳</span>
        </div>
      </div>
    </footer>
  );
}
