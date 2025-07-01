import { ApplicationConfig, provideZoneChangeDetection } from '@angular/core';
import { provideRouter, withComponentInputBinding, withRouterConfig } from '@angular/router';

import { routes } from './app.routes';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { httpInterceptor } from './interceptor/http.interceptor';
import { provideTranslate } from './app.translate';
import { IMAGE_LOADER, ImageLoaderConfig, provideImgixLoader } from '@angular/common';
import { environment } from 'environments/environment';

export const appConfig: ApplicationConfig = {
  providers: [
    provideZoneChangeDetection({ eventCoalescing: true }),
    provideRouter(routes, withComponentInputBinding(), withRouterConfig(
      {
        paramsInheritanceStrategy: 'always'
      }
    )),
    provideHttpClient(
      withInterceptors([httpInterceptor]),
    ),
    provideTranslate(),
    //provideImgixLoader(environment.img),
    {
      provide: IMAGE_LOADER,
      useValue: (config: ImageLoaderConfig) => {
        const img = config.src.split('.');
        const name = img.shift();
        const type = img.pop();
        const width = config.width;
        return `${environment.img}${name}-${width}w.${type}`;
      },
    }
  ],
};
