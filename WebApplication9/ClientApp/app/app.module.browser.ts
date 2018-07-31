import { NgModule, APP_INITIALIZER } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { AppModuleShared } from './app.module.shared';
import { AppComponent } from './components/app/app.component';
import { AppConfiguration } from './app.configuration';

@NgModule({
    bootstrap: [ AppComponent ],
    imports: [
        BrowserModule,
        AppModuleShared
    ],
    providers: [
        // { provide: 'BASE_URL', useFactory: getBaseUrl },
        AppConfiguration, 
        { provide: APP_INITIALIZER, multi: true, useFactory: (getConfig), deps: [AppConfiguration] } 
        // {
        //  provide: APP_INITIALIZER,
        //  useFactory: (config: AppConfiguration) => () => config.loadConfigFromController(),
        //  deps: [AppConfiguration], multi: true 
        // }
    ]
})
export class AppModule {
}

export function getBaseUrl() {
    return document.getElementsByTagName('base')[0].href;
}

//https://stackoverflow.com/questions/46076051/this-appinitsi-is-not-a-function
export function getConfig(config: AppConfiguration) { 
    return () => config.loadConfigFromController();
}
