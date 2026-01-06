/**
 * IronVault - Password Manager for HarmonyOS NEXT
 * Data Model Definitions
 */

/**
 * Represents a stored password entry
 */
export interface PasswordEntry {
  id: number;
  title: string;
  username: string;
  encryptedPassword: string;
  websiteUrl?: string;
  category: string;
  createdAt: number;
  updatedAt: number;
}

/**
 * Category options for password entries
 */
export enum PasswordCategory {
  SOCIAL = 'Social',
  BANKING = 'Banking',
  WORK = 'Work',
  PERSONAL = 'Personal',
  OTHER = 'Other'
}

/**
 * Mock data for UI testing and development
 */
export const MOCK_ENTRIES: PasswordEntry[] = [
  {
    id: 1,
    title: 'Google Account',
    username: 'user@gmail.com',
    encryptedPassword: 'mock_encrypted_password_1',
    websiteUrl: 'https://google.com',
    category: PasswordCategory.SOCIAL,
    createdAt: Date.now() - 86400000 * 30,
    updatedAt: Date.now() - 86400000 * 30
  },
  {
    id: 2,
    title: 'GitHub',
    username: 'developer',
    encryptedPassword: 'mock_encrypted_password_2',
    websiteUrl: 'https://github.com',
    category: PasswordCategory.WORK,
    createdAt: Date.now() - 86400000 * 15,
    updatedAt: Date.now() - 86400000 * 5
  },
  {
    id: 3,
    title: 'Bank of America',
    username: 'john.doe',
    encryptedPassword: 'mock_encrypted_password_3',
    websiteUrl: 'https://bankofamerica.com',
    category: PasswordCategory.BANKING,
    createdAt: Date.now() - 86400000 * 60,
    updatedAt: Date.now() - 86400000 * 2
  }
];

/**
 * Generates a new unique ID for entries
 */
export function generateEntryId(): number {
  return Date.now();
}

/**
 * Creates a new PasswordEntry with timestamps
 */
export function createPasswordEntry(
  title: string,
  username: string,
  encryptedPassword: string,
  category: string,
  websiteUrl?: string
): PasswordEntry {
  const now = Date.now();
  return {
    id: generateEntryId(),
    title,
    username,
    encryptedPassword,
    websiteUrl,
    category,
    createdAt: now,
    updatedAt: now
  };
}
