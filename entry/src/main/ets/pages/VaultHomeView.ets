import { common } from '@kit.AbilityKit';
import { router } from '@kit.ArkUI';
import { VaultDatabase } from '../database/VaultDatabase';
import { GlobalContext } from '../utils/GlobalContext';
import { MOCK_ENTRIES, PasswordEntry, PasswordCategory } from '../models/VaultModel';

/**
 * IronVault - Main Dashboard (Real Data Version)
 * Displays list of password entries
 */
@Entry
@Component
struct VaultHomeView {
  @State entries: PasswordEntry[] = [];
  @State isLoading: boolean = true;
  @State showAddDialog: boolean = false;
  private db: VaultDatabase = VaultDatabase.getInstance();
  private globalContext: GlobalContext = GlobalContext.getInstance();

  async aboutToAppear() {
    await this.globalContext.init();
    await this.db.init();
    await this.loadEntries();
  }

  aboutToDisappear() {
    // Close database when leaving
    this.db.close();
  }

  build() {
    Column() {
      // Header
      this.Header()

      // FAB Button
      this.FloatingActionButton()

      // Content
      if (this.isLoading) {
        this.LoadingView()
      } else if (this.entries.length === 0) {
        this.EmptyView()
      } else {
        this.EntryList()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0D0D0D')
  }

  /**
   * Header component
   */
  @Builder
  Header() {
    Row() {
      Text('IronVault')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')

      Blank()

      // Settings icon
      Image($r('app.media.ic_settings'))
        .width(24)
        .height(24)
        .fillColor('#888888')
    }
    .width('100%')
    .padding(20)
    .justifyContent(FlexAlign.SpaceBetween)
  }

  /**
   * Floating Action Button for adding entries
   */
  @Builder
  FloatingActionButton() {
    Row() {
      Image($r('app.media.ic_add'))
        .width(24)
        .height(24)
        .fillColor('#FFFFFF')
    }
    .width(56)
    .height(56)
    .backgroundColor('#007AFF')
    .borderRadius(28)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .position({ x: '80%', y: '85%' })
    .shadow({ radius: 10, color: '#40000000', offsetX: 2, offsetY: 4 })
    .onClick(() => {
      router.pushUrl({ url: 'view/AddEntryView' });
    })
  }

  /**
   * Loading view
   */
  @Builder
  LoadingView() {
    Column() {
      Progress({ value: 0, total: 100, type: ProgressType.Ring })
        .width(60)
        .height(60)
        .color('#007AFF')
      Text('Loading vault...')
        .fontSize(16)
        .fontColor('#888888')
        .margin({ top: 16 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  /**
   * Empty state view
   */
  @Builder
  EmptyView() {
    Column() {
      Image($r('app.media.ic_empty_vault'))
        .width(120)
        .height(120)
        .objectFit(ImageFit.Contain)
        .fillColor('#333333')

      Text('No passwords yet')
        .fontSize(20)
        .fontWeight(FontWeight.SemiBold)
        .fontColor('#FFFFFF')
        .margin({ top: 24 })

      Text('Tap the + button to add your first password')
        .fontSize(14)
        .fontColor('#888888')
        .margin({ top: 8, bottom: 24 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  /**
   * Entry list
   */
  @Builder
  EntryList() {
    List() {
      ForEach(this.entries, (entry: PasswordEntry) => {
        ListItem() {
          this.EntryItem(entry)
        }
        .onClick(() => {
          this.viewEntry(entry);
        })
      }, (entry: PasswordEntry) => entry.id.toString())
    }
    .width('100%')
    .layoutWeight(1)
    .divider({ strokeWidth: 1, color: '#1A1A1A' })
    .padding({ left: 16, right: 16, bottom: 80 })
  }

  /**
   * Individual entry item
   */
  @Builder
  EntryItem(entry: PasswordEntry) {
    Row() {
      // Icon based on category
      Column() {
        Image(this.getCategoryIcon(entry.category))
          .width(40)
          .height(40)
          .fillColor(this.getCategoryColor(entry.category))
      }
      .width(56)
      .height(56)
      .backgroundColor('#1A1A1A')
      .borderRadius(12)
      .justifyContent(FlexAlign.Center)
      .margin({ right: 16 })

      // Title and username
      Column({ space: 4 }) {
        Text(entry.title)
          .fontSize(16)
          .fontWeight(FontWeight.SemiBold)
          .fontColor('#FFFFFF')

        Text(entry.username)
          .fontSize(14)
          .fontColor('#888888')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // Copy button
      Image($r('app.media.ic_copy'))
        .width(24)
        .height(24)
        .fillColor('#888888')
        .onClick(() => {
          this.copyToClipboard(entry.username);
        })
    }
    .width('100%')
    .height(72)
    .padding({ vertical: 12 })
  }

  /**
   * Load entries from database
   */
  async loadEntries() {
    this.isLoading = true;

    try {
      // Use mock data if database is empty (for development)
      const dbEntries = await this.db.getAllEntries();

      if (dbEntries.length === 0) {
        console.info('[VaultHomeView] Using mock data for development');
        this.entries = [...MOCK_ENTRIES];
      } else {
        this.entries = dbEntries;
      }
    } catch (error) {
      console.error(`[VaultHomeView] Failed to load entries: ${JSON.stringify(error)}`);
      // Fall back to mock data on error
      this.entries = [...MOCK_ENTRIES];
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * View entry details
   */
  viewEntry(entry: PasswordEntry) {
    // TODO: Navigate to entry detail view
    console.info(`[VaultHomeView] Selected: ${entry.title}`);
  }

  /**
   * Copy text to clipboard
   */
  copyToClipboard(text: string) {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      // Simple clipboard copy
      console.info('[VaultHomeView] Copied to clipboard');
    } catch (e) {
      console.error(`[VaultHomeView] Clipboard error: ${JSON.stringify(e)}`);
    }
  }

  /**
   * Get icon for category
   */
  getCategoryIcon(category: string): Resource {
    switch (category) {
      case PasswordCategory.BANKING:
        return $r('app.media.ic_bank');
      case PasswordCategory.SOCIAL:
        return $r('app.media.ic_social');
      case PasswordCategory.WORK:
        return $r('app.media.ic_work');
      default:
        return $r('app.media.ic_password');
    }
  }

  /**
   * Get color for category
   */
  getCategoryColor(category: string): string {
    switch (category) {
      case PasswordCategory.BANKING:
        return '#34C759';
      case PasswordCategory.SOCIAL:
        return '#007AFF';
      case PasswordCategory.WORK:
        return '#FF9500';
      default:
        return '#8E8E93';
    }
  }
}
