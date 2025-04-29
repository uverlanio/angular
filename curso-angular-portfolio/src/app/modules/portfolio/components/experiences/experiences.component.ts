import { Component, signal } from '@angular/core';
import { IExperiences } from '../../interface/IExperiences.interface';

@Component({
  selector: 'app-experiences',
  standalone: true,
  imports: [],
  templateUrl: './experiences.component.html',
  styleUrl: './experiences.component.scss'
})
export class ExperiencesComponent {
  public arrayExperiences = signal<IExperiences[]>([
    {
      summary: {
        strong: 'Salesforce Developer',
        p: 'Globant | Jul 2022 - Present'
      },
      text: '<p>Working with apex language in salesforce, building Rest API, SOQL, Metadata and acting on stories,developing business rules, using agile methodology.</p>'
    },
    {
      summary: {
        strong: 'Java developer',
        p: 'Decision Group |  Dec 2021 - Jul 2022'
      },
      text: '<p>Work on Bradesco acquisition project using Java 8, Spring MVC, Spring Security, Spring Data Redis, Mockito, Rest API, consuming APIs from other projects to deliver to the main project.</p>'    
    },
    {
      summary: {
        strong: 'Java developer',
        p: 'Decision Group | Oct 2020 - Dec 2021'
      },
      text: '<p>Act in the correction of bugs in the APIs of the Intercab project (System Ship Logistics) using Java 8, Spring MVC, Spring Data JPA 2.21, Hibernate, PostgreSQL 14, Rest API and Microsoft Azure Functions.</p>'
    }
  ])

}
