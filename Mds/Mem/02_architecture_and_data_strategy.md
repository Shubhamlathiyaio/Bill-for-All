# Architecture & Data Strategy

## Multi-Tenant Data Isolation Strategy
A highly unique and ambitious requirement of **Bill For All** is its approach to data isolation: **"We will provide each supabase project to each user."**

### Rationale
This architecture ensures ultimate data privacy, security, and scalability. By provisioning a distinct Supabase project (which encompasses a dedicated PostgreSQL database, Auth service, Edge Functions, and Storage bucket) per business/tenant, the system guarantees:
1. **Zero Data Contamination:** It is physically impossible for "User A" to accidentally query or overwrite "User B's" data. There is no "mash" of data at the database level.
2. **Infinite Horizontal Scale:** Global scaling bottlenecks are mitigated since tenants do not share database resources. 
3. **Dedicated Backup and Restore:** Individual users can request rollbacks of their entire operational history without affecting others.

### Implementation Challenges & Considerations
- **Dynamic Supabase Initialization:** The Flutter app must be capable of dynamically initializing its Supabase client based on credentials retrieved during a root login or via deep-links/configuration files provided to the user.
- **Schema Management:** Every time a new feature is pushed to the Flutter app, the backend schema of *every single user's Supabase project* must be migrated simultaneously. We will need a robust CI/CD pipeline or migration script to orchestrate multi-project schema updates.
- **Cost Implications:** Supabase projects carry baseline costs. While providing an entirely separate project per user is technically superior for isolation, it requires an enterprise or high-tier overarching management structure. *Alternatively, this may indicate a "Database per tenant" or "Schema per tenant" architecture within a single Supabase project, which we need to clarify with the user.*

## Storage Paradigms
- **Offline-First:** For users opting for mobile or PC local storage, robust local embedded databases (such as SQLite/Isar) will be used. 
- **Sync Mechanism:** When online storage is enabled, the app must implement bidirectional background sync between the local database and the user's dedicated Supabase project.

## UI Architecture (The "Mash")
While the backend emphasizes total separation, the frontend embraces consolidation. 
- The app maintains a "mash" of feature sets within a single Flutter codebase.
- The UI layer acts as a view engine. Upon login, the app fetches the user's configuration profile (e.g., "Restaurant Mode", "Retail Mode") and dynamically inflates the corresponding UI routes, hiding irrelevant features.
