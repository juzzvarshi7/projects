export interface User {
  id: string;
  name: string;
  email: string;
  role: 'student' | 'admin';
  created_at: string;
}

export interface Item {
  id: string;
  name: string;
  description: string;
  category: string;
  condition: 'new' | 'like-new' | 'good' | 'fair';
  quantity: number;
  expiry_date?: string;
  photo_url: string;
  location: string;
  donor_id: string;
  status: 'available' | 'claimed' | 'completed';
  created_at: string;
  donor?: User;
}

export interface Claim {
  id: string;
  item_id: string;
  claimer_id: string;
  claim_code: string;
  status: 'pending' | 'confirmed' | 'completed';
  created_at: string;
  item?: Item;
  claimer?: User;
}

export interface MoneyBoxEntry {
  id: string;
  amount: number;
  type: 'donation' | 'withdrawal';
  user_id: string;
  reason: string;
  created_at: string;
  user?: User;
}

export interface Voucher {
  id: string;
  type: string;
  value: number;
  donor_id: string;
  claimer_id?: string;
  status: 'available' | 'claimed' | 'used';
  created_at: string;
  donor?: User;
  claimer?: User;
}

export interface AuthContextType {
  user: User | null;
  token: string | null;
  login: (email: string, password: string) => Promise<void>;
  signup: (name: string, email: string, password: string) => Promise<void>;
  logout: () => void;
  loading: boolean;
}