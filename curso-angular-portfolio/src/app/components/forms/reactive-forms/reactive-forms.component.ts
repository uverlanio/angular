import { CommonModule } from '@angular/common';
import { Component, inject, OnInit } from '@angular/core';
import { FormArray, FormBuilder, FormControl, FormGroup, ReactiveFormsModule } from '@angular/forms';

@Component({
  selector: 'app-reactive-forms',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './reactive-forms.component.html',
  styleUrl: './reactive-forms.component.scss'
})
export class ReactiveFormsComponent {
  #fb = inject(FormBuilder);

  public profileForm = this.#fb.group({
    name: [''],
    myStacks: this.#fb.group({
      front: ['Angular'],
      back: ['Java']
    }),
    myFavouriteFoods: this.#fb.array([['X-tudo']])
  })

  public update(){
    this.profileForm.patchValue({
      name: 'Maria',
      myStacks: {
        front: 'Vue',
        back: 'NodeJS'
      }
    })
  }

  public addMyFavouriteFoods(newFood: string){
    const myFavouriteFood = this.profileForm.get('myFavouriteFoods') as FormArray;
    const addNewFood = this.#fb.control(newFood);

    myFavouriteFood.push(addNewFood);
  }
}
