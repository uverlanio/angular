import { ChangeDetectionStrategy, Component, inject, Input, OnInit, signal } from '@angular/core';
import { ActivatedRoute } from '@angular/router';

@Component({
  selector: 'app-servicos-prestado',
  imports: [],
  templateUrl: './servicos-prestado.component.html',
  styleUrl: './servicos-prestado.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class ServicosPrestadoComponent implements OnInit{
  
  #router = inject(ActivatedRoute);

  @Input() set id(id: string){
    this.getId.set(id)
  }

  public getId = signal<null | string>(null);

  ngOnInit(): void { //2 formas de resgatar o id passado por parametro em routes
    console.log(this.#router.snapshot.params['id'])
    this.#router.params.subscribe((res) => console.log(res['id']));
  }
}
