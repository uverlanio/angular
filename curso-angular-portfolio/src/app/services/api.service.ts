import { HttpClient } from '@angular/common/http';
import { inject, Injectable, signal } from '@angular/core';
import { environment } from 'environments/environment';
import { BehaviorSubject, Observable, shareReplay, tap } from 'rxjs';
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
  
  #http = inject(HttpClient);
  #url = signal(environment.apiTask);

  #setListTask = signal<ITask[] | null>(null);
  get getListTask(){
    return this.#setListTask.asReadonly();
  }

  public httpListTask$(): Observable<ITask[]> {
    return this.#http.get<ITask[]>(this.#url()).pipe(
      shareReplay(),
      tap((res) => this.#setListTask.set(res))
    );
  }

  #setTaskId = signal<ITask | null>(null);
  get getTaskId(){
    return this.#setTaskId.asReadonly();
  }

  public httpTaskId$(id: string): Observable<ITask> {
    return this.#http.get<ITask>(`${this.#url()}/${id}`).pipe(
      shareReplay(),
      tap((res) => this.#setTaskId.set(res))
    );
  }

  #setTaskCreate = signal<ITask | null>(null);
  get getTaskCreate(){
    return this.#setTaskCreate.asReadonly();
  }
  public httpTaskCreate$(title : string): Observable<ITask> {
    return this.#http.post<ITask>(this.#url(), { title }).pipe(
      shareReplay(),
      tap((res) => this.#setTaskCreate.set(res))
    );
  }
}
