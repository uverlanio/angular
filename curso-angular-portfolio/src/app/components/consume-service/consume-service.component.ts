import { CommonModule } from '@angular/common';
import { HttpClient } from '@angular/common/http';
import {
  ChangeDetectionStrategy,
  Component,
  inject,
  OnInit,
  signal,
} from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { NewComponent } from 'app/modules/portfolio/components/new-component/new.component';
import { ApiService } from 'app/services/api.service';
import { concatMap, map, Observable, timeInterval } from 'rxjs';

@Component({
  selector: 'app-consume-service',
  imports: [CommonModule],
  standalone: true,
  templateUrl: './consume-service.component.html',
  styleUrl: './consume-service.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})

export class ConsumeServiceComponent implements OnInit {

  #apiService = inject(ApiService);
  public getTaskList = this.#apiService.getTaskList;
  public getTaskId = this.#apiService.getTaskId;

  ngOnInit(): void {
    this.#apiService.httpTaskList$().subscribe();
  }

  public httpTaskCreate(title: string){
    return this.#apiService
      .httpTaskCreate$(title)
      .pipe(map(() => this.#apiService.httpTaskList$()))
      .subscribe(taskList$ => this.#apiService.httpTaskList$().subscribe());
  }

   public httpTaskUpdate(id: string, title: string){
    return this.#apiService
      .httpTaskUpdate$(id, title)
      .pipe(map(() => this.#apiService.httpTaskList$()))
      .subscribe(taskList$ => this.#apiService.httpTaskList$().subscribe());
  }

  public httpTaskDelete(id: string){
    return this.#apiService
      .httpTaskDelete$(id)
      .pipe(map(() => this.#apiService.httpTaskList$()))
      .subscribe(taskList$ => this.#apiService.httpTaskList$().subscribe());
  }
}
