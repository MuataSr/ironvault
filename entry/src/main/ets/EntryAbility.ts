import { UIAbility } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';

export default class EntryAbility extends UIAbility {
  onCreate(want, launchParam) {
    console.info('[EntryAbility] onCreate');
  }

  onDestroy() {
    console.info('[EntryAbility] onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    console.info('[EntryAbility] onWindowStageCreate');

    windowStage.loadContent('view/LoginView', (err, data) => {
      if (err.code) {
        console.error(`[EntryAbility] Failed to load content: ${JSON.stringify(err)}`);
        return;
      }
      console.info('[EntryAbility] Succeeded in loading content');
    });
  }

  onWindowStageDestroy() {
    console.info('[EntryAbility] onWindowStageDestroy');
  }

  onForeground() {
    console.info('[EntryAbility] onForeground');
  }

  onBackground() {
    console.info('[EntryAbility] onBackground');
  }
}
