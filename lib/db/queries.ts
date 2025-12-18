'use server'

import prisma from '@/lib/prisma';
import type { DatabaseUserInput, SearchResult, WorkspaceCreateInput } from './types';


/**
 * Generate a consistent room ID for 1-on-1 chats based on user emails
 * Uses email because it persists even if user is deleted and recreated (UID changes)
 * Format: room_<email1>_<email2> where emails are sorted alphabetically
 */
function generateRoomId(email1: string, email2: string): string {
    const emails = [email1.toLowerCase(), email2.toLowerCase()].sort();
    return `room_${emails[0]}_${emails[1]}`;
}


export async function getAllUsers(maxResults?: number, nextPage?: number) {
    try {
        const limit = maxResults || 1000;
        const page = nextPage || 1;
        const skip = (page - 1) * limit;

        const [users, totalCount] = await Promise.all([
            prisma.users.findMany({
                where: {
                    deleted: false
                },
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
            prisma.users.count({
                where: {
                    deleted: false
                }
            }),
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
                deleted: false,
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

export async function createUser(data: DatabaseUserInput | null, workspaceId?: string) {
    if (!data) {
        console.error("user: Input is null in createUser");
        throw new Error("User input data is required")
    }

    try {
        const result = await prisma.$transaction(async (tx) => {

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

            const user = await tx.users.create({
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

            const workspaceName = user.name
                ? `${user.name}'s Workspace`
                : `${user.email.split('@')[0]}'s Workspace`

            const workspaceData: WorkspaceCreateInput = {
                name: workspaceName,
                description: 'Personal workspace',
                ownerId: user.uid,
                tenantId: user.tenantId,
                type: 'personal',
                disabled: false
            }

            if (workspaceId) {
                workspaceData.id = workspaceId
            }

            const workspace = await tx.workspaces.create({
                data: workspaceData,
                select: {
                    id: true,
                    name: true,
                    type: true,
                    createdAt: true
                }
            })

            await tx.workspaceMembers.create({
                data: {
                    workspaceId: workspace.id,
                    userId: user.uid,
                    role: 'owner'
                }
            })

            return {
                user,
                workspace: {
                    id: workspace.id,
                    name: workspace.name,
                    type: workspace.type
                }
            }
        })

        return result;
    } catch (error) {
        console.error('Failed to create user in database:', error);
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


/**
 * Soft delete user (anonymize email to release it for reuse)
 * @param uid 
 * @returns 
 */
export async function softDeleteUser(uid: string) {
    try {
        const user = await prisma.users.findUnique({
            where: { uid },
            select: { email: true, deleted: true }
        });

        if (!user) {
            return {
                success: false,
                error: { code: 'USER_NOT_FOUND', message: 'User not found' }
            };
        }

        if (user.deleted) {
            return {
                success: true,
                message: 'User already deleted'
            };
        }

        // Anonymize email to release it for reuse with new Firebase UID
        const anonymizedEmail = `deleted_${uid}@deleted.local`;

        await prisma.users.update({
            where: { uid },
            data: {
                deleted: true,
                deletedAt: new Date(),
                disabled: true,
                originalEmail: user.email,  // Preserve original email
                email: anonymizedEmail,      // Release email for reuse
            }
        });

        return {
            success: true,
            message: 'User soft deleted successfully'
        };
    } catch (error) {
        console.error('Error soft deleting user:', error);
        return {
            success: false,
            error: {
                code: 'DELETE_ERROR',
                message: error instanceof Error ? error.message : 'Failed to delete user'
            }
        };
    }
}


export async function getUserChats(uid: string, workspaceId?: string) {
    try {
        const whereConditions: any[] = [];

        whereConditions.push({
            type: 'direct',
            OR: [
                { senderId: uid },
                { recipientId: uid }
            ]
        });

        if (workspaceId) {
            whereConditions.push({
                type: 'workspace',
                workspaceId: workspaceId,
                OR: [
                    { senderId: uid },
                    { recipientId: uid }
                ]
            });
        }

        const userChats = await prisma.chats.findMany({
            where: {
                OR: whereConditions
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

/**
 * getChatMessages - Fetch messages for a specific chat within a workspace
 * @param chatId 
 * @param workspaceId
 * @returns 
 */
export async function getChatMessages(chatId: string, workspaceId?: string) {
    try {
        const whereCondition: any = { chatId: chatId };


        if (workspaceId) {
            whereCondition.chat = {
                workspaceId: workspaceId
            };
        }

        const messages = await prisma.messages.findMany({
            where: whereCondition,
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


export async function createNewChat(currentUserId: string, otherUserId: string, workspaceId: string, initialMessage: string) {
    try {
        const [currentUser, otherUser] = await Promise.all([
            prisma.users.findUnique({
                where: { uid: currentUserId },
                select: { tenantId: true, email: true }
            }),
            prisma.users.findUnique({
                where: { uid: otherUserId },
                select: { email: true }
            })
        ]);

        if (!currentUser || !otherUser) {
            return {
                success: false,
                error: {
                    code: 'USER_NOT_FOUND',
                    message: 'One or both users not found'
                }
            };
        }

        if (currentUser.tenantId === 'default') {
            const isContact = await areContacts(currentUserId, otherUserId);

            if (!isContact) {
                return {
                    success: false,
                    error: {
                        code: 'NOT_CONTACT',
                        message: 'Cannot chat with non-contact. Add them to your contacts first.'
                    }
                };
            }
        }

        const roomId = generateRoomId(currentUser.email, otherUser.email);

        const existingChat = await prisma.chats.findFirst({
            where: {
                roomId: roomId,
                type: 'direct'
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
                        orderBy: { createdAt: 'desc' },
                        take: 1
                    }
                }
            });

            return {
                success: true,
                chat: updatedChat,
                isExisting: true,
                roomId
            };
        }

        const chat = await prisma.chats.create({
            data: {
                senderId: currentUserId,
                recipientId: otherUserId,
                roomId: roomId,
                type: 'direct',
                lastMessage: new Date(),
                messages: {
                    create: {
                        content: initialMessage,
                        senderId: currentUserId,
                    }
                }
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
                messages: true
            }
        });

        return {
            success: true,
            chat,
            roomId
        };
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


export async function markMessagesAsRead(chatId: string, currentUserId: string, workspaceId?: string) {
    try {
        const whereCondition: any = {
            id: chatId,
            OR: [
                { senderId: currentUserId },
                { recipientId: currentUserId }
            ]
        };

        if (workspaceId) {
            whereCondition.workspaceId = workspaceId;
        }

        const chat = await prisma.chats.findFirst({
            where: whereCondition
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

/**
 * getWorkspace - Fetch a specific workspace by ID, ensuring the user is a member
 * @param workspaceId 
 * @param userId 
 * @returns 
 */
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

/**
 * Create a new workspace as well as adding the owner as a member
 * @param ownerId 
 * @param tenantId 
 * @param name 
 * @param description 
 * @param type 
 * @returns 
 */
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

/**
 * Delete a workspace - only the owner can delete
 * @param workspaceId 
 * @param userId 
 * @returns 
 */
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



/**
 * Get members of a workspace, ensuring the requesting user is a member
 * @param workspaceId 
 * @param userId 
 * @returns 
 */
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

/**
 * Invite a user to join a workspace
 * @param workspaceId 
 * @param inviterId 
 * @param inviteeId 
 * @param role 
 * @returns 
 */
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

/**
 * Remove a member from a workspace
 * @param workspaceId 
 * @param requesterId 
 * @param memberId 
 * @returns 
 */
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

/**
 * Update Workspace Member Role
 * @param workspaceId 
 * @param requesterId 
 * @param memberId 
 * @param newRole 
 * @returns 
 */
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

/**
 * Search users within a workspace
 * @param workspaceId 
 * @param currentUserId 
 * @param query 
 * @param limit 
 * @returns 
 */
export async function searchWorkspaceUsers(workspaceId: string, currentUserId: string, query: string, limit: number = 10) {
    try {
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


/**
 * Get user's contacts (workspace - independent)
*/
export async function getMyContacts(userId: string) {
    try {
        const contacts = await prisma.contacts.findMany({
            where: {
                userId: userId,
                status: 'accepted'
            },
            include: {
                contact: {
                    select: {
                        uid: true,
                        name: true,
                        email: true,
                        avatar: true,
                        phoneNumber: true,
                        tenantId: true
                    }
                }
            },
            orderBy: {
                createdAt: 'desc'
            }
        });

        return {
            success: true,
            contacts: contacts.map(c => ({
                ...c.contact,
                addedAt: c.createdAt,
                status: c.status
            }))
        };
    } catch (error) {
        console.error('Error fetching contacts:', error);
        return {
            success: false,
            error: {
                code: 'FETCH_CONTACTS_ERROR',
                message: error instanceof Error ? error.message : 'Failed to fetch contacts'
            }
        };
    }
}

// Search my contacts only
export async function searchMyContacts(userId: string, query: string, limit: number = 20) {
    try {
        const contacts = await prisma.contacts.findMany({
            where: {
                userId: userId,
                status: 'accepted',
                contact: {
                    OR: [
                        { name: { contains: query, mode: 'insensitive' } },
                        { email: { contains: query, mode: 'insensitive' } },
                        { phoneNumber: { contains: query, mode: 'insensitive' } }
                    ]
                }
            },
            include: {
                contact: {
                    select: {
                        uid: true,
                        name: true,
                        email: true,
                        avatar: true,
                        phoneNumber: true
                    }
                }
            },
            take: limit
        });

        return {
            success: true,
            contacts: contacts.map(c => c.contact)
        };
    } catch (error) {
        console.error('Error searching contacts:', error);
        return {
            success: false,
            error: {
                code: 'SEARCH_ERROR',
                message: error instanceof Error ? error.message : 'Failed to search contacts'
            }
        };
    }
}

/**
 * Add contact (bidirectional, workspace-independent)
*/
export async function addContact(inviterId: string, inviteeIdentifier: string) {
    try {
        return await prisma.$transaction(async (tx) => {
            const invitee = await tx.users.findFirst({
                where: {
                    deleted: false,
                    OR: [
                        { email: inviteeIdentifier.toLowerCase() },
                        { phoneNumber: inviteeIdentifier },
                        { uid: inviteeIdentifier }
                    ]
                }
            });

            if (!invitee) {
                return {
                    success: false,
                    error: {
                        code: 'USER_NOT_FOUND',
                        message: 'User not found'
                    }
                };
            }

            if (invitee.uid === inviterId) {
                return {
                    success: false,
                    error: {
                        code: 'INVALID_REQUEST',
                        message: 'Cannot add yourself as contact'
                    }
                };
            }

            // Check if contact relationship already exists
            const existingContact = await tx.contacts.findFirst({
                where: {
                    userId: inviterId,
                    contactId: invitee.uid
                }
            });

            if (existingContact) {
                return {
                    success: false,
                    error: {
                        code: 'ALREADY_CONTACT',
                        message: 'User is already in your contacts'
                    }
                };
            }

            // Create bidirectional contact relationship
            await Promise.all([
                // Add invitee to inviter's contacts
                tx.contacts.create({
                    data: {
                        userId: inviterId,
                        contactId: invitee.uid,
                        status: 'accepted'
                    }
                }),
                // Add inviter to invitee's contacts (bidirectional)
                tx.contacts.create({
                    data: {
                        userId: invitee.uid,
                        contactId: inviterId,
                        status: 'accepted'
                    }
                })
            ]);

            return {
                success: true,
                contact: {
                    uid: invitee.uid,
                    name: invitee.name,
                    email: invitee.email,
                    avatar: invitee.avatar,
                    phoneNumber: invitee.phoneNumber
                }
            };
        });
    } catch (error) {
        console.error('Error adding contact:', error);
        return {
            success: false,
            error: {
                code: 'ADD_CONTACT_ERROR',
                message: error instanceof Error ? error.message : 'Failed to add contact'
            }
        };
    }
}

/**
 * Remove contact (bidirectional, workspace-independent)
*/
export async function removeContact(userId: string, contactId: string) {
    try {
        return await prisma.$transaction(async (tx) => {
            // Delete bidirectional contact relationships
            await Promise.all([
                tx.contacts.deleteMany({
                    where: {
                        userId: userId,
                        contactId: contactId
                    }
                }),
                tx.contacts.deleteMany({
                    where: {
                        userId: contactId,
                        contactId: userId
                    }
                })
            ]);

            return { success: true };
        });
    } catch (error) {
        console.error('Error removing contact:', error);
        return {
            success: false,
            error: {
                code: 'REMOVE_CONTACT_ERROR',
                message: error instanceof Error ? error.message : 'Failed to remove contact'
            }
        };
    }
}

/**
 * Check if two users are contacts (workspace-independent)
*/
export async function areContacts(userId1: string, userId2: string): Promise<boolean> {
    const contact = await prisma.contacts.findFirst({
        where: {
            userId: userId1,
            contactId: userId2,
            status: 'accepted'
        }
    });

    return !!contact;
}