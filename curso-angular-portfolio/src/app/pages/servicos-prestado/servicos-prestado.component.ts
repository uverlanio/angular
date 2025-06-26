import { ChangeDetectionStrategy, Component, inject, Input, OnInit, signal } from '@angular/core';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';

@Component({
  selector: 'app-servicos-prestado',
  imports: [ReactiveFormsModule, RouterLink],
  templateUrl: './servicos-prestado.component.html',
  styleUrl: './servicos-prestado.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export default class ServicosPrestadoComponent implements OnInit {
  #route = inject(ActivatedRoute);
  #router = inject(Router)

  @Input() set id(id: string) {
    this.getId.set(id);
  }

  public getId = signal<null | string>(null);

  public form = new FormGroup({
    name: new FormControl(null, [Validators.required])
  });

  ngOnInit(): void {
    //2 formas de resgatar o id passado por parametro em routes
    /*console.log(this.#route.snapshot.params['id'])
    this.#route.params.subscribe((res) => console.log(res['id']));*/

    this.#route.queryParamMap.subscribe((res) => console.log(res.get('name')));

    this.#route.queryParamMap.subscribe({
      next: (next) => console.log(next.get('age')),
    });

    //setTimeout(() =>  this.#router.navigate(['/curso']), 3000)
   
  }
}
