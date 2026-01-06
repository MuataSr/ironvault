import { router } from '@kit.ArkUI';

/**
 * IronVault - Login Screen
 * Master password entry screen
 */
@Entry
@Component
struct LoginView {
  @State masterPassword: string = '';
  @State isLoading: boolean = false;
  @State errorMessage: string = '';

  build() {
    Column() {
      // Spacer
      Blank()
        .height('20%')

      // Logo/Icon Area
      Column() {
        Image($r('app.media.ic_launcher'))
          .width(100)
          .height(100)
          .objectFit(ImageFit.Contain)
          .alt($r('app.media.ic_launcher_round'))

        Text('IronVault')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 16, bottom: 8 })

        Text('Your passwords, secured.')
          .fontSize(14)
          .fontColor('#888888')
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)

      // Spacer
      Blank()
        .height('10%')

      // Password Input
      Column({ space: 12 }) {
        TextInput({ placeholder: 'Enter Master Key', text: this.masterPassword })
          .type(InputType.Password)
          .width('85%')
          .height(56)
          .backgroundColor('#1A1A1A')
          .borderRadius(12)
          .padding({ left: 16, right: 16 })
          .fontSize(16)
          .onChange((value: string) => {
            this.masterPassword = value;
            this.errorMessage = '';
          })

        // Error message
        if (this.errorMessage) {
          Text(this.errorMessage)
            .fontSize(14)
            .fontColor('#FF6B6B')
            .width('85%')
            .textAlign(TextAlign.Start)
        }

        // Unlock Button
        Button(this.isLoading ? 'Unlocking...' : 'Unlock Vault')
          .width('85%')
          .height(56)
          .backgroundColor('#007AFF')
          .fontSize(18)
          .fontWeight(FontWeight.SemiBold)
          .borderRadius(12)
          .enabled(!this.isLoading && this.masterPassword.length > 0)
          .onClick(() => {
            this.handleLogin();
          })
          .margin({ top: 8 })
      }
      .width('100%')

      // Spacer
      Blank()
        .height('25%')

      // Footer
      Text('Offline Password Manager')
        .fontSize(12)
        .fontColor('#555555')
        .margin({ bottom: 24 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0D0D0D')
  }

  /**
   * Handle login attempt
   */
  async handleLogin() {
    if (this.masterPassword.length === 0) {
      this.errorMessage = 'Please enter your master password';
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';

    try {
      // TODO: Validate master password against stored hash
      // For now, accept any non-empty password

      console.info('[LoginView] Vault unlocked successfully');

      // Navigate to home
      router.replaceUrl({
        url: 'pages/VaultHomeView'
      });
    } catch (error) {
      this.errorMessage = 'Failed to unlock vault. Please try again.';
      console.error(`[LoginView] Login error: ${JSON.stringify(error)}`);
    } finally {
      this.isLoading = false;
    }
  }
}
