import { router } from '@kit.ArkUI';
import { PasswordCategory, createPasswordEntry } from '../models/VaultModel';
import { CryptoManager } from '../utils/CryptoManager';

/**
 * IronVault - Add Entry View
 * Form for adding new password entries
 */
@Entry
@Component
struct AddEntryView {
  @State title: string = '';
  @State username: string = '';
  @State password: string = '';
  @State websiteUrl: string = '';
  @State category: string = PasswordCategory.OTHER;
  @State showPassword: boolean = false;
  @State isLoading: boolean = false;
  @State isSaving: boolean = false;

  private categories: string[] = Object.values(PasswordCategory);
  private masterPassword: string = '';

  build() {
    Column() {
      // Header with back button
      this.Header()

      // Form content
      Scroll() {
        Column({ space: 20 }) {
          // Title
          this.FormField('Title', 'e.g., Google Account', this.title, (value) => {
            this.title = value;
          }, false)

          // Username
          this.FormField('Username', 'e.g., user@example.com', this.username, (value) => {
            this.username = value;
          }, false)

          // Password with visibility toggle
          Column({ space: 8 }) {
            Text('Password')
              .fontSize(14)
              .fontColor('#888888')
              .width('85%')
              .textAlign(TextAlign.Start)

            Row() {
              TextInput({ placeholder: 'Enter password', text: this.password })
                .type(this.showPassword ? InputType.Normal : InputType.Password)
                .width('85%')
                .height(56)
                .backgroundColor('#1A1A1A')
                .borderRadius(12)
                .padding({ left: 16, right: 16 })
                .fontSize(16)
                .onChange((value: string) => {
                  this.password = value;
                })

              Image(this.showPassword ? $r('app.media.ic_eye_off') : $r('app.media.ic_eye'))
                .width(24)
                .height(24)
                .fillColor('#888888')
                .width(50)
                .height(56)
                .onClick(() => {
                  this.showPassword = !this.showPassword;
                })
            }
            .width('85%')
            .justifyContent(FlexAlign.SpaceBetween)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          // Website URL
          this.FormField('Website URL (Optional)', 'https://example.com', this.websiteUrl, (value) => {
            this.websiteUrl = value;
          }, false)

          // Category dropdown
          Column({ space: 8 }) {
            Text('Category')
              .fontSize(14)
              .fontColor('#888888')
              .width('85%')
              .textAlign(TextAlign.Start)

            Select(this.categories.map((cat: string) => ({ value: cat })))
              .width('85%')
              .height(56)
              .backgroundColor('#1A1A1A')
              .borderRadius(12)
              .padding({ left: 16, right: 16 })
              .selected(this.categories.indexOf(this.category))
              .onSelect((index: number) => {
                this.category = this.categories[index];
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          // Generate password button
          Row() {
            Image($r('app.media.ic_generate'))
              .width(20)
              .height(20)
              .fillColor('#007AFF')
              .margin({ right: 8 })

            Text('Generate Secure Password')
              .fontSize(16)
              .fontColor('#007AFF')
          }
          .width('85%')
          .height(48)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.generatePassword();
          })

          // Spacer
          Blank()
            .height(20)

          // Save Button
          Button('Save Password')
            .width('85%')
            .height(56)
            .backgroundColor(this.isFormValid() ? '#007AFF' : '#333333')
            .fontSize(18)
            .fontWeight(FontWeight.SemiBold)
            .borderRadius(12)
            .enabled(this.isFormValid() && !this.isSaving)
            .onClick(() => {
              this.saveEntry();
            })

          // Spacer
          Blank()
            .height(40)
        }
        .width('100%')
        .padding({ top: 20 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0D0D0D')
  }

  /**
   * Header with back button
   */
  @Builder
  Header() {
    Row() {
      Image($r('app.media.ic_back'))
        .width(24)
        .height(24)
        .fillColor('#FFFFFF')
        .onClick(() => {
          router.back();
        })

      Text('Add Password')
        .fontSize(20)
        .fontWeight(FontWeight.SemiBold)
        .fontColor('#FFFFFF')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
        .margin({ right: 24 })
    }
    .width('100%')
    .padding(20)
  }

  /**
   * Reusable form field
   */
  @Builder
  FormField(
    label: string,
    placeholder: string,
    value: string,
    onChange: (value: string) => void,
    isPassword: boolean
  ) {
    Column({ space: 8 }) {
      Text(label)
        .fontSize(14)
        .fontColor('#888888')
        .width('85%')
        .textAlign(TextAlign.Start)

      TextInput({ placeholder: placeholder, text: value })
        .type(isPassword ? InputType.Password : InputType.Normal)
        .width('85%')
        .height(56)
        .backgroundColor('#1A1A1A')
        .borderRadius(12)
        .padding({ left: 16, right: 16 })
        .fontSize(16)
        .onChange(onChange)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  /**
   * Check if form is valid
   */
  isFormValid(): boolean {
    return this.title.length > 0 &&
      this.username.length > 0 &&
      this.password.length > 0;
  }

  /**
   * Generate a secure random password
   */
  generatePassword() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+';
    let password = '';
    const randomArray = new Uint32Array(16);
    cryptoFramework.createRandom({ size: 64 });

    for (let i = 0; i < 16; i++) {
      password += chars[Math.floor(Math.random() * chars.length)];
    }

    this.password = password;
  }

  /**
   * Save the new entry
   */
  async saveEntry() {
    if (!this.isFormValid()) return;

    this.isSaving = true;

    try {
      // TODO: Get master password from secure storage
      // For now, use a placeholder (should come from login flow)
      const masterKey = 'placeholder-master-key';

      // Encrypt the password
      const encryptedPassword = await CryptoManager.encrypt(this.password, masterKey);

      // Create entry object
      const newEntry = createPasswordEntry(
        this.title,
        this.username,
        encryptedPassword,
        this.category,
        this.websiteUrl || undefined
      );

      // TODO: Save to database
      console.info(`[AddEntryView] New entry created: ${JSON.stringify(newEntry)}`);

      // Navigate back
      router.back();
    } catch (error) {
      console.error(`[AddEntryView] Failed to save: ${JSON.stringify(error)}`);
    } finally {
      this.isSaving = false;
    }
  }
}
