import { Injectable, NotFoundException } from '@nestjs/common';

import { CreateNewTaskRequestDto, TaskResponseDto, UpdateTaskRequestDto } from './dto';

@Injectable()
export class TasksService {
  // TODO: 실제 DB, Drizzle 등 객체를 주입하여 수정
  // // eslint-disable-next-line @typescript-eslint/require-await 지우기

  constructor() {}

  // Task 생성
  // eslint-disable-next-line @typescript-eslint/require-await
  async create(createNewTaskDto: CreateNewTaskRequestDto): Promise<TaskResponseDto> {
    const mockCreatedTask: TaskResponseDto = {
      id: '550e8400-e29b-41d4-a716-446655440000',
      task_number: 1,
      title: createNewTaskDto.title,
      description: createNewTaskDto.description,
      assignee_handle: createNewTaskDto.assignee_handle,
      status: createNewTaskDto.status,
      priority: createNewTaskDto.priority,
      assignee_nickname: '홍길동',
      reporter_nickname: '김코시',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    };

    return mockCreatedTask;
  }

  // Task 목록 조회
  // eslint-disable-next-line @typescript-eslint/require-await
  async findAll(): Promise<TaskResponseDto[]> {
    return [];
  }

  // Task 상세 조회
  // eslint-disable-next-line @typescript-eslint/require-await
  async findOne(task_number: number): Promise<TaskResponseDto> {
    const taskFound = false;
    if (!taskFound) {
      throw new NotFoundException(`Task with number ${task_number} not found`);
    }

    return {} as TaskResponseDto;
  }

  // Task 수정
  // eslint-disable-next-line @typescript-eslint/require-await
  async update(task_number: number, updateTaskDto: UpdateTaskRequestDto): Promise<TaskResponseDto> {
    // 존재 여부 확인 후 수정 로직 구현
    console.log(`수정할 번호: ${task_number}`);
    console.log(`수정할 제목: ${updateTaskDto.title}`);
    return {} as TaskResponseDto;
  }

  // Task 삭제
  // eslint-disable-next-line @typescript-eslint/require-await
  async remove(task_number: number): Promise<void> {
    // 존재 여부 체크 후 삭제 로직 구현
    console.log(`삭제할 번호: ${task_number}`);
  }
}
