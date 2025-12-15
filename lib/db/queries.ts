'use server'

import prisma from '@/lib/prisma';
import type { DatabaseUserInput, SearchResult } from './types';


export async function getAllUsers(maxResults?: number, nextPage?: number) {
    try {
        const limit = maxResults || 1000;
        const page = nextPage || 1;
        const skip = (page - 1) * limit;

        const [users, totalCount] = await Promise.all([
            prisma.users.findMany({
                select: {
                    uid: true,
                    email: true,
                    phoneNumber: true,
                    tenantId: true,
                    disabled: true,
                    createdAt: true,
                    lastSignInAt: true,
                    isAdmin: true,
                },
                skip,
                take: limit,
                orderBy: {
                    createdAt: 'desc',
                },
            }),
            prisma.users.count(),
        ]);

        const totalPages = Math.ceil(totalCount / limit);

        return {
            success: true,
            users,
            totalCount,
            totalPages,
            currentPage: page,
            hasMore: page < totalPages,
        };
    } catch (error) {
        console.error('Error fetching all users:', error);
        return {
            success: false,
            error: {
                code: 'FETCH_USERS_ERROR',
                message: error instanceof Error ? error.message : 'Failed to fetch users',
            },
        };
    }
}

export async function getUser(uid: string) {
    try {
        const dbUser = await prisma.users.findUnique({
            where: { uid },
            select: {
                uid: true,
                email: true,
                emailVerified: true,
            }
        })

        if (!dbUser) {
            return {
                success: false,
                error: {
                    code: 'USER_NOT_FOUND',
                    message: 'User not found'
                },
            }
        }
        return {
            success: true,
            user: dbUser
        }
    } catch (error) {
        return {
            success: false,
            error: {
                code: 'DB_ERROR',
                message: error instanceof Error ? error.message : 'Failed to get user from database'
            }
        }
    }
}

export async function searchUsers(query: string, limit: number = 10): Promise<SearchResult> {
    try {
        const dbUser = await prisma.users.findMany({
            where: {
                OR: [
                    {
                        name: {
                            contains: query,
                            mode: 'insensitive', // Case-insensitive search
                        },
                    },
                    {
                        email: {
                            contains: query,
                            mode: 'insensitive',
                        },
                    },
                ],
            },
            select: {
                uid: true,
                name: true,
                email: true,
                avatar: true,
            },
            take: limit,
        });

        return {
            success: true,
            users: dbUser.map((user: { uid: string; name: string | null; email: string; avatar: string | null }) => ({
                uid: user.uid,
                name: user.name || user.email?.split('@')[0],
                email: user.email,
                avatar: user.avatar ?? undefined,
            })),
        };
    } catch (error) {
        console.error('Error searching users:', error);
        return {
            success: false,
            error: {
                code: 'SEARCH_ERROR',
                message: error instanceof Error ? error.message : 'Failed to search users',
            },
        };
    }
}

export async function createUser(data: DatabaseUserInput | null) {
    if (!data) {
        console.error("user: Input is null in createUser");
        throw new Error("User input data is required")
    }

    try {
        const sanitizedData = {
            uid: data.uid,
            email: data.email.toLowerCase(),
            name: data.name,
            avatar: data.avatar,
            tenantId: data.tenantId,
            isAdmin: data.isAdmin,
            phoneNumber: data.phoneNumber,
            emailVerified: data.emailVerified,
            createdAt: data.createdAt,
            lastSignInAt: data.lastSignInAt,
            updatedAt: new Date(),
            disabled: false
        }
        const user = await prisma.users.create({
            data: sanitizedData,
            select: {
                uid: true,
                email: true,
                name: true,
                avatar: true,
                tenantId: true,
                isAdmin: true,
                phoneNumber: true,
                emailVerified: true,
                disabled: true,
                updatedAt: true,
                createdAt: true,
                lastSignInAt: true,
            },
        });

        if (!user) {
            throw new Error("Failed to create user: No user returned from database")
        }
        return user;
    } catch (error) {
        console.error('Failed to create user in database');
        throw error;
    }
}

export async function updateUser(uid: string, data: Partial<DatabaseUserInput>) {
    try {
        const existingUser = await prisma.users.findUnique({
            where: { uid },
            select: { uid: true }
        });

        if (!existingUser) {
            return {
                success: false,
                error: {
                    code: 'USER_NOT_FOUND',
                    message: 'User not found'
                }
            };
        }

        const updateData: any = {
            updatedAt: new Date()
        };

        if (data.email !== undefined) updateData.email = data.email.toLowerCase();
        if (data.name !== undefined) updateData.name = data.name;
        if (data.avatar !== undefined) updateData.avatar = data.avatar;
        if (data.tenantId !== undefined) updateData.tenantId = data.tenantId;
        if (data.isAdmin !== undefined) updateData.isAdmin = data.isAdmin;
        if (data.phoneNumber !== undefined) updateData.phoneNumber = data.phoneNumber;
        if (data.emailVerified !== undefined) updateData.emailVerified = data.emailVerified;
        if (data.lastSignInAt !== undefined) updateData.lastSignInAt = data.lastSignInAt;
        if (data.disabled !== undefined) updateData.disabled = data.disabled;

        const user = await prisma.users.update({
            where: { uid },
            data: updateData,
            select: {
                uid: true,
                email: true,
                name: true,
                avatar: true,
                tenantId: true,
                isAdmin: true,
                phoneNumber: true,
                emailVerified: true,
                disabled: true,
                updatedAt: true,
                createdAt: true,
                lastSignInAt: true,
            },
        });

        return {
            success: true,
            user
        };
    } catch (error) {
        console.error('Failed to update user in database:', error);
        return {
            success: false,
            error: {
                code: 'DB_ERROR',
                message: error instanceof Error ? error.message : 'Failed to update user'
            }
        };
    }
}


export async function getUserChats(uid: string, workspaceId: string) {
    try {
        const userChats = await prisma.chats.findMany({
            where: {
                AND: [
                    {
                        OR: [
                            { senderId: uid },
                            { recipientId: uid }
                        ]
                    },
                    { workspaceId: workspaceId } // Ensure tenant isolation
                ]
            },
            orderBy: {
                lastMessage: 'desc'
            },
            include: {
                sender: {
                    select: {
                        uid: true,
                        name: true,
                        email: true,
                        avatar: true,
                    }
                },
                recipient: {
                    select: {
                        uid: true,
                        name: true,
                        email: true,
                        avatar: true,
                    }
                },
                messages: {
                    take: 1,
                    orderBy: {
                        createdAt: 'desc'
                    },
                    select: {
                        id: true,
                        content: true,
                        createdAt: true,
                        read: true,
                        senderId: true,
                    }
                }
            }
        });

        return { success: true, chats: userChats };
    } catch (error) {
        console.error('Error fetching user chats:', error);
        return {
            success: false,
            error: {
                code: 'FETCH_CHATS_ERROR',
                message: error instanceof Error ? error.message : 'Failed to fetch chats'
            }
        };
    }
}

// Get chat messages
export async function getChatMessages(chatId: string, workspaceId: string) {
    try {
        const messages = await prisma.messages.findMany({
            where: {
                chatId: chatId,
                chat: {
                    workspaceId: workspaceId // Ensure tenant isolation
                }
            },
            orderBy: {
                createdAt: 'desc'
            },
            include: {
                sender: {
                    select: {
                        uid: true,
                        name: true,
                        email: true,
                        avatar: true,
                    }
                }
            }
        });

        return { success: true, messages };
    } catch (error) {
        console.error('Error fetching chat messages:', error);
        return {
            success: false,
            error: {
                code: 'FETCH_MESSAGES_ERROR',
                message: error instanceof Error ? error.message : 'Failed to fetch messages'
            }
        };
    }
}

// Create new chat with initial message
export async function createNewChat(currentUserId: string, otherUserId: string, workspaceId: string, initialMessage: string) {
    try {
        // Check if chat already exists
        const existingChat = await prisma.chats.findFirst({
            where: {
                AND: [
                    {
                        OR: [
                            { AND: [{ senderId: currentUserId }, { recipientId: otherUserId }] },
                            { AND: [{ senderId: otherUserId }, { recipientId: currentUserId }] }
                        ]
                    },
                    { workspaceId: workspaceId }
                ]
            }
        });

        if (existingChat) {
            const newMessage = await prisma.messages.create({
                data: {
                    content: initialMessage,
                    senderId: currentUserId,
                    chatId: existingChat.id
                }
            });

            await prisma.chats.update({
                where: { id: existingChat.id },
                data: { lastMessage: new Date() }
            });

            const updatedChat = await prisma.chats.findUnique({
                where: { id: existingChat.id },
                include: {
                    messages: {
                        orderBy: { createdAt: 'desc' },
                        take: 1
                    }
                }
            });

            return {
                success: true,
                chat: updatedChat,
                isExisting: true
            };
        }

        const chat = await prisma.chats.create({
            data: {
                senderId: currentUserId,
                recipientId: otherUserId,
                workspaceId: workspaceId,
                lastMessage: new Date(),
                messages: {
                    create: {
                        content: initialMessage,
                        senderId: currentUserId,
                    }
                }
            },
            include: {
                messages: true
            }
        });

        return { success: true, chat };
    } catch (error) {
        console.error('Error creating new chat:', error);
        return {
            success: false,
            error: {
                code: 'CREATE_CHAT_ERROR',
                message: error instanceof Error ? error.message : 'Failed to create chat'
            }
        };
    }
}

// Mark messages as read
export async function markMessagesAsRead(chatId: string, currentUserId: string, workspaceId: string) {
    try {
        // Verify chat belongs to tenant and user is participant
        const chat = await prisma.chats.findFirst({
            where: {
                id: chatId,
                workspaceId: workspaceId,
                OR: [
                    { senderId: currentUserId },
                    { recipientId: currentUserId }
                ]
            }
        });

        if (!chat) {
            return {
                success: false,
                error: {
                    code: 'CHAT_NOT_FOUND',
                    message: 'Chat not found or access denied'
                }
            };
        }

        const markAsRead = await prisma.messages.updateMany({
            where: {
                chatId: chatId,
                senderId: {
                    not: currentUserId
                },
                read: false
            },
            data: {
                read: true,
                readAt: new Date()
            }
        });

        return { success: true, updatedCount: markAsRead.count };
    } catch (error) {
        console.error('Error marking messages as read:', error);
        return {
            success: false,
            error: {
                code: 'UPDATE_READ_STATUS_ERROR',
                message: error instanceof Error ? error.message : 'Failed to mark messages as read'
            }
        };
    }
}



// ==================== WORKSPACE QUERIES ====================

export async function getAllWorkspaces(maxResults?: number, nextPage?: number) {
    try {
        const limit = maxResults || 1000;
        const page = nextPage || 1;
        const skip = (page - 1) * limit;

        const [workspaces, totalCount] = await Promise.all([
            prisma.workspaces.findMany({
                select: {
                    id: true,
                    name: true,
                    description: true,
                    ownerId: true,
                    tenantId: true,
                    type: true,
                    disabled: true,
                    createdAt: true,
                    updatedAt: true,
                    _count: {
                        select: {
                            workspaceMembers: true,
                            chats: true,
                        }
                    },
                    owner: {
                        select: {
                            uid: true,
                            name: true,
                            email: true,
                            avatar: true,
                        }
                    }
                },
                skip,
                take: limit,
                orderBy: {
                    createdAt: 'desc',
                },
            }),
            prisma.workspaces.count(),
        ]);

        const totalPages = Math.ceil(totalCount / limit);

        return {
            success: true,
            workspaces,
            totalCount,
            totalPages,
            currentPage: page,
            hasMore: page < totalPages,
        };
    } catch (error) {
        console.error('Error fetching all workspaces:', error);
        return {
            success: false,
            error: {
                code: 'FETCH_WORKSPACES_ERROR',
                message: error instanceof Error ? error.message : 'Failed to fetch workspaces',
            },
        };
    }
}

export async function getUserWorkspaces(userId: string) {
    try {
        const workspaces = await prisma.workspaces.findMany({
            where: {
                workspaceMembers: {
                    some: {
                        userId: userId
                    }
                }
            },
            include: {
                owner: {
                    select: {
                        uid: true,
                        name: true,
                        email: true,
                        avatar: true,
                    }
                },
                workspaceMembers: {
                    include: {
                        user: {
                            select: {
                                uid: true,
                                name: true,
                                email: true,
                                avatar: true,
                            }
                        }
                    }
                },
                _count: {
                    select: {
                        workspaceMembers: true,
                        chats: true,
                    }
                }
            },
            orderBy: {
                createdAt: 'desc'
            }
        });

        return { success: true, workspaces };
    } catch (error) {
        console.error('Error fetching user workspaces:', error);
        return {
            success: false,
            error: {
                code: 'FETCH_WORKSPACES_ERROR',
                message: error instanceof Error ? error.message : 'Failed to fetch workspaces'
            }
        };
    }
}

// Get single workspace details
export async function getWorkspace(workspaceId: string, userId: string) {
    try {
        const workspace = await prisma.workspaces.findFirst({
            where: {
                id: workspaceId,
                workspaceMembers: {
                    some: {
                        userId: userId
                    }
                }
            },
            include: {
                owner: {
                    select: {
                        uid: true,
                        name: true,
                        email: true,
                        avatar: true,
                    }
                },
                tenant: {
                    select: {
                        id: true,
                        name: true,
                        domain: true,
                    }
                },
                workspaceMembers: {
                    include: {
                        user: {
                            select: {
                                uid: true,
                                name: true,
                                email: true,
                                avatar: true,
                                phoneNumber: true,
                            }
                        }
                    },
                    orderBy: {
                        joinedAt: 'asc'
                    }
                },
                _count: {
                    select: {
                        chats: true,
                    }
                }
            }
        });

        if (!workspace) {
            return {
                success: false,
                error: {
                    code: 'WORKSPACE_NOT_FOUND',
                    message: 'Workspace not found or access denied'
                }
            };
        }

        return { success: true, workspace };
    } catch (error) {
        console.error('Error fetching workspace:', error);
        return {
            success: false,
            error: {
                code: 'FETCH_WORKSPACE_ERROR',
                message: error instanceof Error ? error.message : 'Failed to fetch workspace'
            }
        };
    }
}

// Create workspace with owner as first member
export async function createWorkspace(
    ownerId: string,
    tenantId: string,
    name: string,
    description?: string,
    type: 'personal' | 'business' = 'personal'
) {
    try {
        const workspace = await prisma.workspaces.create({
            data: {
                name,
                description,
                ownerId,
                tenantId,
                type,
                workspaceMembers: {
                    create: {
                        userId: ownerId,
                        role: 'owner'
                    }
                }
            },
            include: {
                owner: {
                    select: {
                        uid: true,
                        name: true,
                        email: true,
                        avatar: true,
                    }
                },
                workspaceMembers: {
                    include: {
                        user: {
                            select: {
                                uid: true,
                                name: true,
                                email: true,
                                avatar: true,
                            }
                        }
                    }
                }
            }
        });

        return { success: true, workspace };
    } catch (error) {
        console.error('Error creating workspace:', error);
        return {
            success: false,
            error: {
                code: 'CREATE_WORKSPACE_ERROR',
                message: error instanceof Error ? error.message : 'Failed to create workspace'
            }
        };
    }
}

// Update workspace
export async function updateWorkspace(
    workspaceId: string,
    userId: string,
    data: { name?: string; description?: string; disabled?: boolean; settings?: any }
) {
    try {
        // Verify user is owner or admin
        const membership = await prisma.workspaceMembers.findFirst({
            where: {
                workspaceId,
                userId,
                role: { in: ['owner', 'admin'] }
            }
        });

        if (!membership) {
            return {
                success: false,
                error: {
                    code: 'UNAUTHORIZED',
                    message: 'Only workspace owners or admins can update workspace'
                }
            };
        }

        const workspace = await prisma.workspaces.update({
            where: { id: workspaceId },
            data: {
                ...data,
                updatedAt: new Date()
            },
            include: {
                owner: {
                    select: {
                        uid: true,
                        name: true,
                        email: true,
                    }
                }
            }
        });

        return { success: true, workspace };
    } catch (error) {
        console.error('Error updating workspace:', error);
        return {
            success: false,
            error: {
                code: 'UPDATE_WORKSPACE_ERROR',
                message: error instanceof Error ? error.message : 'Failed to update workspace'
            }
        };
    }
}

// Delete workspace (only owner)
export async function deleteWorkspace(workspaceId: string, userId: string) {
    try {
        const workspace = await prisma.workspaces.findFirst({
            where: {
                id: workspaceId,
                ownerId: userId
            }
        });

        if (!workspace) {
            return {
                success: false,
                error: {
                    code: 'UNAUTHORIZED',
                    message: 'Only workspace owner can delete workspace'
                }
            };
        }

        await prisma.workspaces.delete({
            where: { id: workspaceId }
        });

        return { success: true };
    } catch (error) {
        console.error('Error deleting workspace:', error);
        return {
            success: false,
            error: {
                code: 'DELETE_WORKSPACE_ERROR',
                message: error instanceof Error ? error.message : 'Failed to delete workspace'
            }
        };
    }
}



// ==================== WORKSPACE MEMBER QUERIES ====================

// Get workspace members
export async function getWorkspaceMembers(workspaceId: string, userId: string) {
    try {
        // Verify user is member of workspace
        const isMember = await prisma.workspaceMembers.findFirst({
            where: {
                workspaceId,
                userId
            }
        });

        if (!isMember) {
            return {
                success: false,
                error: {
                    code: 'UNAUTHORIZED',
                    message: 'Access denied to workspace'
                }
            };
        }

        const members = await prisma.workspaceMembers.findMany({
            where: { workspaceId },
            include: {
                user: {
                    select: {
                        uid: true,
                        name: true,
                        email: true,
                        avatar: true,
                        phoneNumber: true,
                        disabled: true,
                    }
                }
            },
            orderBy: [
                { role: 'asc' }, // owner first, then admin, then member
                { joinedAt: 'asc' }
            ]
        });

        return { success: true, members };
    } catch (error) {
        console.error('Error fetching workspace members:', error);
        return {
            success: false,
            error: {
                code: 'FETCH_MEMBERS_ERROR',
                message: error instanceof Error ? error.message : 'Failed to fetch members'
            }
        };
    }
}

// Invite user to workspace
export async function inviteToWorkspace(
    workspaceId: string,
    inviterId: string,
    inviteeId: string,
    role: 'member' | 'admin' = 'member'
) {
    try {
        // Verify inviter has permission (owner or admin)
        const inviterMembership = await prisma.workspaceMembers.findFirst({
            where: {
                workspaceId,
                userId: inviterId,
                role: { in: ['owner', 'admin'] }
            }
        });

        if (!inviterMembership) {
            return {
                success: false,
                error: {
                    code: 'UNAUTHORIZED',
                    message: 'Only workspace owners or admins can invite members'
                }
            };
        }

        // Check if user already member
        const existingMember = await prisma.workspaceMembers.findFirst({
            where: {
                workspaceId,
                userId: inviteeId
            }
        });

        if (existingMember) {
            return {
                success: false,
                error: {
                    code: 'ALREADY_MEMBER',
                    message: 'User is already a member of this workspace'
                }
            };
        }

        // Verify invitee exists and is in same tenant
        const [invitee, workspace] = await Promise.all([
            prisma.users.findUnique({ where: { uid: inviteeId } }),
            prisma.workspaces.findUnique({ where: { id: workspaceId } })
        ]);

        if (!invitee || !workspace) {
            return {
                success: false,
                error: {
                    code: 'NOT_FOUND',
                    message: 'User or workspace not found'
                }
            };
        }

        if (invitee.tenantId !== workspace.tenantId) {
            return {
                success: false,
                error: {
                    code: 'TENANT_MISMATCH',
                    message: 'User must be in the same tenant as workspace'
                }
            };
        }

        const member = await prisma.workspaceMembers.create({
            data: {
                workspaceId,
                userId: inviteeId,
                role,
                invitedBy: inviterId
            },
            include: {
                user: {
                    select: {
                        uid: true,
                        name: true,
                        email: true,
                        avatar: true,
                    }
                }
            }
        });

        return { success: true, member };
    } catch (error) {
        console.error('Error inviting to workspace:', error);
        return {
            success: false,
            error: {
                code: 'INVITE_ERROR',
                message: error instanceof Error ? error.message : 'Failed to invite user'
            }
        };
    }
}

// Remove member from workspace
export async function removeMemberFromWorkspace(
    workspaceId: string,
    requesterId: string,
    memberId: string
) {
    try {
        // Get requester and member info
        const [requesterMembership, memberToRemove, workspace] = await Promise.all([
            prisma.workspaceMembers.findFirst({
                where: { workspaceId, userId: requesterId }
            }),
            prisma.workspaceMembers.findFirst({
                where: { workspaceId, userId: memberId }
            }),
            prisma.workspaces.findUnique({
                where: { id: workspaceId }
            })
        ]);

        if (!workspace || !requesterMembership || !memberToRemove) {
            return {
                success: false,
                error: {
                    code: 'NOT_FOUND',
                    message: 'Workspace or member not found'
                }
            };
        }

        // Can't remove the owner
        if (memberId === workspace.ownerId) {
            return {
                success: false,
                error: {
                    code: 'CANNOT_REMOVE_OWNER',
                    message: 'Cannot remove workspace owner'
                }
            };
        }

        // Check permissions: owner can remove anyone, admin can remove members, members can remove themselves
        const canRemove =
            requesterMembership.role === 'owner' ||
            (requesterMembership.role === 'admin' && memberToRemove.role === 'member') ||
            requesterId === memberId;

        if (!canRemove) {
            return {
                success: false,
                error: {
                    code: 'UNAUTHORIZED',
                    message: 'Insufficient permissions to remove member'
                }
            };
        }

        await prisma.workspaceMembers.delete({
            where: { id: memberToRemove.id }
        });

        return { success: true };
    } catch (error) {
        console.error('Error removing member from workspace:', error);
        return {
            success: false,
            error: {
                code: 'REMOVE_MEMBER_ERROR',
                message: error instanceof Error ? error.message : 'Failed to remove member'
            }
        };
    }
}

// Update member role
export async function updateMemberRole(
    workspaceId: string,
    requesterId: string,
    memberId: string,
    newRole: 'admin' | 'member'
) {
    try {
        // Verify requester is owner or admin
        const [requesterMembership, memberToUpdate, workspace] = await Promise.all([
            prisma.workspaceMembers.findFirst({
                where: { workspaceId, userId: requesterId }
            }),
            prisma.workspaceMembers.findFirst({
                where: { workspaceId, userId: memberId }
            }),
            prisma.workspaces.findUnique({
                where: { id: workspaceId }
            })
        ]);

        if (!workspace || !requesterMembership || !memberToUpdate) {
            return {
                success: false,
                error: {
                    code: 'NOT_FOUND',
                    message: 'Workspace or member not found'
                }
            };
        }

        // Only owner can change roles
        if (requesterMembership.role !== 'owner') {
            return {
                success: false,
                error: {
                    code: 'UNAUTHORIZED',
                    message: 'Only workspace owner can change member roles'
                }
            };
        }

        // Can't change owner's role
        if (memberId === workspace.ownerId) {
            return {
                success: false,
                error: {
                    code: 'CANNOT_CHANGE_OWNER_ROLE',
                    message: 'Cannot change workspace owner role'
                }
            };
        }

        const updatedMember = await prisma.workspaceMembers.update({
            where: { id: memberToUpdate.id },
            data: { role: newRole },
            include: {
                user: {
                    select: {
                        uid: true,
                        name: true,
                        email: true,
                        avatar: true,
                    }
                }
            }
        });

        return { success: true, member: updatedMember };
    } catch (error) {
        console.error('Error updating member role:', error);
        return {
            success: false,
            error: {
                code: 'UPDATE_ROLE_ERROR',
                message: error instanceof Error ? error.message : 'Failed to update role'
            }
        };
    }
}

// Search users within workspace
export async function searchWorkspaceUsers(workspaceId: string, currentUserId: string, query: string, limit: number = 10) {
    try {
        // Verify user is member of workspace
        const isMember = await prisma.workspaceMembers.findFirst({
            where: {
                workspaceId,
                userId: currentUserId
            }
        });

        if (!isMember) {
            return {
                success: false,
                error: {
                    code: 'UNAUTHORIZED',
                    message: 'Access denied to workspace'
                }
            };
        }

        const members = await prisma.workspaceMembers.findMany({
            where: {
                workspaceId,
                user: {
                    OR: [
                        { name: { contains: query, mode: 'insensitive' } },
                        { email: { contains: query, mode: 'insensitive' } }
                    ]
                }
            },
            include: {
                user: {
                    select: {
                        uid: true,
                        name: true,
                        email: true,
                        avatar: true,
                    }
                }
            },
            take: limit
        });

        return {
            success: true,
            users: members.map((m) => ({
                ...m.user,
                role: m.role,
                joinedAt: m.joinedAt
            }))
        };
    } catch (error) {
        console.error('Error searching workspace users:', error);
        return {
            success: false,
            error: {
                code: 'SEARCH_ERROR',
                message: error instanceof Error ? error.message : 'Failed to search users'
            }
        };
    }
}