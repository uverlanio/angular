import { Injectable, signal } from '@angular/core';
import { BehaviorSubject } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class ApiService {

  // novo
  public name = signal('Uver');

  // antigo
  public name$ = new BehaviorSubject('Uver $');

  constructor() {}
}
