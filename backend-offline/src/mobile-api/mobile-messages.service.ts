import { Injectable } from '@nestjs/common';

type MobileMessage = {
  id: string;
  fromCompany: boolean;
  text: string;
  createdAt: string;
};

@Injectable()
export class MobileMessagesService {
  private readonly messages: MobileMessage[] = [];

  list(): MobileMessage[] {
    return [...this.messages].sort((a, b) =>
      a.createdAt < b.createdAt ? 1 : -1,
    );
  }

  add(fromCompany: boolean, text: string): MobileMessage {
    const item: MobileMessage = {
      id: `msg_${Date.now()}`,
      fromCompany,
      text,
      createdAt: new Date().toISOString(),
    };
    this.messages.push(item);
    return item;
  }
}
