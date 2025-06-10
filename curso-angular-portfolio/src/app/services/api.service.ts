import { HttpClient } from '@angular/common/http';
import { Injectable, signal } from '@angular/core';
import { environment } from 'environments/environment';
import { BehaviorSubject, Observable, shareReplay } from 'rxjs';
interface ITask {
    id: string;
    title: string;
  }

@Injectable({
  providedIn: 'root',
})
export class ApiService { 
  
  public name = signal('Uver');
  public name$ = new BehaviorSubject('Uver $');

  constructor(private _http: HttpClient) {}
  
  private _url = signal(environment.apiTask);

  public httpListTask$(): Observable<ITask[]> {
    return this._http.get<ITask[]>(this._url()).pipe(shareReplay());
  }
}
