import { IUpdateWorkspaceRequest } from '@cosider/shared';
import { IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class UpdateWorkspaceRequest implements IUpdateWorkspaceRequest {
  @IsString()
  @IsNotEmpty()
  name!: string;

  @IsString()
  @IsOptional()
  description!: string | null;

  @IsString()
  @IsNotEmpty()
  slug!: string;
}
