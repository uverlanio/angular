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

  #setTaskList = signal<ITask[] | null>(null);
  get getTaskList(){
    return this.#setTaskList.asReadonly();
  }

  public httpTaskList$(): Observable<ITask[]> {
    return this.#http.get<ITask[]>(this.#url()).pipe(
      shareReplay(),
      tap((res) => this.#setTaskList.set(res))
    );
  }

  #setTaskId = signal<ITask | null>(null);
  get getTaskId(){
    return this.#setTaskId.asReadonly();
  }

  public httpTaskId$(id: string): Observable<ITask> {
    return this.#http.get<ITask>(`${this.#url()}/${id}`).pipe(shareReplay());
  }

  public httpTaskCreate$(title : string): Observable<ITask> {
    return this.#http.post<ITask>(this.#url(), { title }).pipe(shareReplay());
  }

  public httpTaskUpdate$(id: string, title : string): Observable<ITask> {
    return this.#http.patch<ITask>(`${this.#url()}/${id}`, { title }).pipe(shareReplay());
  }

  public httpTaskDelete$(id: string): Observable<void> {
     return this.#http.delete<void>(`${this.#url()}/${id}`).pipe(shareReplay());
  }
}
